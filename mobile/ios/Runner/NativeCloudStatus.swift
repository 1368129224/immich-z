import CryptoKit
import Foundation
import Photos

struct NativeCloudSyncCache: Codable {
  var matchedServerIDs: [String: String] = [:] // localIdentifier -> serverAssetId
  var checkedIDs: [String] = []                // localIdentifiers that were checked
  var checksums: [String: String] = [:]        // localIdentifier -> SHA1 hex string
}

final class NativeSyncCacheStore: @unchecked Sendable {
  static let shared = NativeSyncCacheStore()
  private let lock = NSLock()
  private let fileURL: URL
  private(set) var matchedServerIDs: [String: String] = [:] // localId -> serverId
  private(set) var reverseMatches: [String: String] = [:]   // serverId -> localId
  private(set) var checkedIDs: Set<String> = []
  private(set) var checksums: [String: String] = [:]
  private let saveQueue = DispatchQueue(label: "immich.sync.cache.save", qos: .utility)

  init() {
    let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    fileURL = folder.appendingPathComponent("native_cloud_sync_cache.json")

    var isDirty = false
    if let data = try? Data(contentsOf: fileURL),
       let decoded = try? JSONDecoder().decode(NativeCloudSyncCache.self, from: data) {
      // Purge any legacy bogus entries where localId == serverId
      matchedServerIDs = decoded.matchedServerIDs.filter { $0.key != $0.value }
      checkedIDs = Set(decoded.checkedIDs)
      // Purge legacy 40-char hex checksums so they are re-hashed to Base64 SHA-1
      checksums = decoded.checksums.filter { $0.value.count != 40 }
      for (localId, serverId) in matchedServerIDs {
        reverseMatches[serverId] = localId
      }
      if matchedServerIDs.count != decoded.matchedServerIDs.count || checksums.count != decoded.checksums.count {
        isDirty = true
      }
    }

    // Import from Flutter backup markers in UserDefaults if present (only marks as checked, not fake match)
    if let markersRaw = UserDefaults.standard.string(forKey: "flutter.backup_markers"),
       let markersData = markersRaw.data(using: .utf8),
       let ids = try? JSONSerialization.jsonObject(with: markersData) as? [String] {
      for id in ids {
        if checkedIDs.insert(id).inserted {
          isDirty = true
        }
      }
    }

    if isDirty {
      saveToDisk()
    }
  }

  func isMatched(localId: String?) -> Bool {
    guard let localId else { return false }
    lock.lock(); defer { lock.unlock() }
    return matchedServerIDs[localId] != nil
  }

  func serverID(for localId: String) -> String? {
    lock.lock(); defer { lock.unlock() }
    return matchedServerIDs[localId]
  }

  func localID(for serverId: String) -> String? {
    lock.lock(); defer { lock.unlock() }
    return reverseMatches[serverId]
  }

  func update(matches: [String: String] = [:], checked: Set<String> = [], newChecksums: [String: String] = [:]) {
    lock.lock()
    var changed = false
    for (k, v) in matches {
      if matchedServerIDs[k] != v {
        matchedServerIDs[k] = v
        reverseMatches[v] = k
        changed = true
      }
    }
    for id in checked {
      if checkedIDs.insert(id).inserted {
        changed = true
      }
    }
    for (k, v) in newChecksums {
      if checksums[k] != v {
        checksums[k] = v
        changed = true
      }
    }
    lock.unlock()

    if changed {
      saveToDisk()
    }
  }

  func clear() {
    lock.lock()
    matchedServerIDs.removeAll()
    reverseMatches.removeAll()
    checkedIDs.removeAll()
    checksums.removeAll()
    lock.unlock()
    try? FileManager.default.removeItem(at: fileURL)
  }

  private func saveToDisk() {
    lock.lock()
    let snapshot = NativeCloudSyncCache(
      matchedServerIDs: matchedServerIDs,
      checkedIDs: Array(checkedIDs),
      checksums: checksums
    )
    lock.unlock()

    saveQueue.async { [fileURL] in
      if let data = try? JSONEncoder().encode(snapshot) {
        try? data.write(to: fileURL, options: .atomic)
      }
    }
  }
}

// The server confirms an uploaded copy only when its SHA1 matches the actual
// PhotoKit original resource. Unreadable or cloud-only originals stay unknown.
@MainActor
final class NativeCloudStatus: ObservableObject {
  @Published private(set) var matchedServerIDs: [String: String]
  @Published private(set) var checkedIDs: Set<String>
  @Published private(set) var message: String?
  @Published private(set) var failedCount = 0
  @Published private(set) var isRunning = false
  private var checksums: [String: String]
  private var running = false
  private var generation = 0
  private var failedIDs: Set<String> = []

  init() {
    let store = NativeSyncCacheStore.shared
    self.matchedServerIDs = store.matchedServerIDs
    self.checkedIDs = store.checkedIDs
    self.checksums = store.checksums
  }

  func reset() {
    generation += 1
    failedIDs = []
    failedCount = 0
    message = nil
    running = false
    isRunning = false
  }

  func clearCache() {
    reset()
    matchedServerIDs = [:]
    checkedIDs = []
    checksums = [:]
    NativeSyncCacheStore.shared.clear()
  }

  func retry(_ assets: [NativeDeviceAsset], client: NativeImmichClient) async {
    let retryWithNetwork = !failedIDs.isEmpty
    if retryWithNetwork { failedIDs = [] }
    await check(assets, client: client, allowNetwork: retryWithNetwork)
    if failedCount > 0 && message == nil {
      message = "有 \(failedCount) 项原件暂时无法读取；可下载 iCloud 原件后重新核验。"
    }
  }

  func check(_ assets: [NativeDeviceAsset], client: NativeImmichClient, allowNetwork: Bool = false) async {
    let syncEnabled = UserDefaults.standard.object(forKey: "backup_enabled") as? Bool ?? true
    guard syncEnabled else {
      message = "同步已暂停"
      return
    }
    guard !running else { return }
    let toCheck = assets.filter { matchedServerIDs[$0.id] == nil && (allowNetwork || !failedIDs.contains($0.id)) }
    guard !toCheck.isEmpty else { return }

    running = true
    isRunning = true
    let current = generation
    defer {
      if current == generation {
        running = false
        isRunning = false
        failedCount = failedIDs.count
      }
    }
    message = nil

    for batch in stride(from: 0, to: toCheck.count, by: 50) {
      guard current == generation else { return }
      let slice = Array(toCheck[batch..<min(batch + 50, toCheck.count)])

      var hashes: [[String: String]] = []
      var newlyComputedChecksums: [String: String] = [:]

      await withTaskGroup(of: (String, String?).self) { group in
        for asset in slice {
          if let cached = checksums[asset.id] {
            group.addTask { (asset.id, cached) }
          } else {
            group.addTask(priority: .utility) {
              let hash = await Self.checksum(for: asset, allowNetwork: allowNetwork)
              return (asset.id, hash)
            }
          }
        }
        for await (id, hash) in group {
          if let hash {
            hashes.append(["id": id, "checksum": hash])
            newlyComputedChecksums[id] = hash
          } else {
            failedIDs.insert(id)
          }
        }
      }

      guard current == generation else { return }
      if !newlyComputedChecksums.isEmpty {
        for (k, v) in newlyComputedChecksums { checksums[k] = v }
        NativeSyncCacheStore.shared.update(newChecksums: newlyComputedChecksums)
      }

      guard !hashes.isEmpty else { continue }

      do {
        let response = try await client.send(path: "assets/bulk-upload-check", method: "POST", body: ["assets": hashes])
        guard current == generation else { return }
        guard let results = response["results"] as? [[String: Any]] else {
          message = "服务器的上传状态核验响应格式异常。"
          return
        }

        let submitted = Set(hashes.compactMap { $0["id"] })
        var received = Set<String>()
        var newMatches: [String: String] = [:]
        var newChecked: Set<String> = []

        for result in results {
          guard let id = result["id"] as? String, submitted.contains(id), received.insert(id).inserted else { continue }
          newChecked.insert(id)
          if result["action"] as? String == "reject" {
            let serverID = (result["assetId"] as? String) ?? id
            newMatches[id] = serverID
          }
        }

        for (k, v) in newMatches { matchedServerIDs[k] = v }
        checkedIDs.formUnion(newChecked)
        NativeSyncCacheStore.shared.update(matches: newMatches, checked: newChecked)

        let omitted = submitted.subtracting(received).count
        if omitted > 0 { message = "服务器没有返回 \(omitted) 项的核验结果，状态暂时未知。" }
      } catch {
        message = "无法向服务器核验上传状态：\(error.localizedDescription)"
        return
      }
    }
  }

  nonisolated private static func checksum(for deviceAsset: NativeDeviceAsset, allowNetwork: Bool) async -> String? {
    guard let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [deviceAsset.id], options: nil).firstObject else { return nil }
    guard let resource = phAsset.getResource() else { return nil }

    final class RequestRef: @unchecked Sendable {
      var id: PHAssetResourceDataRequestID?
    }
    let requestRef = RequestRef()

    return await withTaskCancellationHandler(operation: {
      if Task.isCancelled { return nil }
      let options = PHAssetResourceRequestOptions()
      options.isNetworkAccessAllowed = allowNetwork

      return await withCheckedContinuation { continuation in
        var hasher = Insecure.SHA1()
        requestRef.id = PHAssetResourceManager.default().requestData(
          for: resource,
          options: options,
          dataReceivedHandler: { bytes in
            hasher.update(data: bytes)
          },
          completionHandler: { error in
            if error != nil {
              continuation.resume(returning: nil)
            } else {
              // Immich canonical checksum format: Base64 encoded SHA1 hash
              let base64Hash = Data(hasher.finalize()).base64EncodedString()
              continuation.resume(returning: base64Hash)
            }
          }
        )
      }
    }, onCancel: {
      if let requestId = requestRef.id {
        PHAssetResourceManager.default().cancelDataRequest(requestId)
      }
    })
  }
}

// Resource selection mirrors official Immich app PHAssetExtensions.swift
extension PHAsset {
  func getResource() -> PHAssetResource? {
    let resources = PHAssetResource.assetResources(for: self)
    let filteredResources = resources.filter { $0.isMediaResource && isValidResourceType($0.type) }

    guard !filteredResources.isEmpty else { return nil }

    if filteredResources.count == 1 {
      return filteredResources.first
    }

    if let currentResource = filteredResources.first(where: { $0.isCurrent }) {
      return currentResource
    }

    if let fullSizeResource = filteredResources.first(where: { isFullSizeResourceType($0.type) }) {
      return fullSizeResource
    }

    return filteredResources.first
  }

  private func isValidResourceType(_ type: PHAssetResourceType) -> Bool {
    switch mediaType {
    case .image:
      return [.photo, .alternatePhoto, .fullSizePhoto].contains(type)
    case .video:
      return [.video, .fullSizeVideo, .fullSizePairedVideo].contains(type)
    default:
      return false
    }
  }

  private func isFullSizeResourceType(_ type: PHAssetResourceType) -> Bool {
    switch mediaType {
    case .image:
      return type == .fullSizePhoto
    case .video:
      return type == .fullSizeVideo
    default:
      return false
    }
  }
}

// Resource properties mirror official Immich app PHAssetResourceExtensions.swift
extension PHAssetResource {
  var isCurrent: Bool {
    return (value(forKey: "isCurrent") as? Bool) ?? false
  }

  var isMediaResource: Bool {
    var isMedia = type != .adjustmentData
    if #available(iOS 17, *) {
      isMedia = isMedia && type != .photoProxy
    }
    return isMedia
  }
}

import CryptoKit
import Foundation
import Photos

// The server confirms an uploaded copy only when its SHA1 matches the actual
// PhotoKit original resource. Unreadable or cloud-only originals stay unknown.
@MainActor
final class NativeCloudStatus: ObservableObject {
  @Published private(set) var matchedServerIDs: [String: String] = [:]
  @Published private(set) var checkedIDs: Set<String> = []
  @Published private(set) var message: String?
  @Published private(set) var failedCount = 0
  private var running = false
  private var generation = 0
  private var failedIDs: Set<String> = []

  func reset() {
    generation += 1
    matchedServerIDs = [:]
    checkedIDs = []
    failedIDs = []
    failedCount = 0
    message = nil
    running = false
  }

  func retry(_ assets: [NativeDeviceAsset], client: NativeImmichClient) async {
    let retryWithNetwork = !failedIDs.isEmpty
    if retryWithNetwork { failedIDs = [] }
    await check(assets, client: client, allowNetwork: retryWithNetwork)
  }

  func check(_ assets: [NativeDeviceAsset], client: NativeImmichClient, allowNetwork: Bool = false) async {
    guard !running else { return }
    running = true
    let current = generation
    defer {
      if current == generation {
        running = false
        failedCount = failedIDs.count
        if failedCount > 0 && message == nil {
          message = "有 \(failedCount) 项原件暂时无法读取；可下载 iCloud 原件后重新核验。"
        }
      }
    }
    message = nil

    for batch in stride(from: 0, to: assets.count, by: 50) {
      guard current == generation else { return }
      var hashes: [[String: String]] = []
      for asset in assets[batch..<min(batch + 50, assets.count)]
      where !checkedIDs.contains(asset.id) && matchedServerIDs[asset.id] == nil && (allowNetwork || !failedIDs.contains(asset.id)) {
        failedIDs.remove(asset.id)
        if let hash = await Task.detached(priority: .utility, operation: {
          await Self.checksum(for: asset, allowNetwork: allowNetwork)
        }).value {
          hashes.append(["id": asset.id, "checksum": hash])
        } else {
          failedIDs.insert(asset.id)
        }
      }
      guard current == generation else { return }
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
        for result in results {
          guard let id = result["id"] as? String, submitted.contains(id), received.insert(id).inserted else { continue }
          if result["action"] as? String == "accept" {
            checkedIDs.insert(id)
          } else if result["action"] as? String == "reject",
                    result["reason"] as? String == "duplicate",
                    let serverID = result["assetId"] as? String, !serverID.isEmpty {
            matchedServerIDs[id] = serverID
            checkedIDs.insert(id)
          }
          // Unknown action/reason is deliberately left unverified.
        }
        let omitted = submitted.subtracting(received).count
        if omitted > 0 { message = "服务器没有返回 \(omitted) 项的核验结果，状态暂时未知。" }
      } catch {
        message = "无法向服务器核验上传状态：\(error.localizedDescription)"
        return // Network, permission, and proxy errors must not imply not uploaded.
      }
    }
  }

  nonisolated private static func checksum(for deviceAsset: NativeDeviceAsset, allowNetwork: Bool) async -> String? {
    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [deviceAsset.id], options: nil).firstObject else { return nil }
    let resources = PHAssetResource.assetResources(for: asset)
    let preferredTypes: [PHAssetResourceType] = deviceAsset.isVideo ? [.video, .fullSizeVideo] : [.photo, .fullSizePhoto]
    guard let resource = preferredTypes.lazy.compactMap({ type in resources.first(where: { $0.type == type }) }).first else { return nil }

    let options = PHAssetResourceRequestOptions()
    options.isNetworkAccessAllowed = allowNetwork
    let digest = NativeSHA1Accumulator()
    return await withCheckedContinuation { continuation in
      PHAssetResourceManager.default().requestData(for: resource, options: options, dataReceivedHandler: { bytes in
        digest.append(bytes)
      }, completionHandler: { error in
        continuation.resume(returning: error == nil ? digest.hex() : nil)
      })
    }
  }
}

private final class NativeSHA1Accumulator {
  private var hasher = Insecure.SHA1()
  private let lock = NSLock()
  func append(_ data: Data) { lock.lock(); hasher.update(data: data); lock.unlock() }
  func hex() -> String {
    lock.lock(); defer { lock.unlock() }
    return hasher.finalize().map { String(format: "%02x", $0) }.joined()
  }
}

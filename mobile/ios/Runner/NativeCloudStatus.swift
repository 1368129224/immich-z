import CryptoKit
import Foundation
import Photos

// The server only confirms identity through an original-file checksum match. A
// filename, date or thumbnail resemblance must never be treated as an upload.
@MainActor
final class NativeCloudStatus: ObservableObject {
  @Published private(set) var matchedServerIDs: [String: String] = [:]
  @Published private(set) var checkedIDs: Set<String> = []
  private var running = false
  private var generation = 0
  private var failedIDs: Set<String> = []

  func reset() {
    generation += 1
    matchedServerIDs = [:]
    checkedIDs = []
    failedIDs = []
    running = false
  }

  func check(_ assets: [NativeDeviceAsset], client: NativeImmichClient) async {
    guard !running else { return }
    running = true
    let current = generation
    defer { if current == generation { running = false } }
    for batch in stride(from: 0, to: assets.count, by: 50) {
      guard current == generation else { return }
      // Hashing originals is expensive: run away from the main actor and
      // publish only completed batches so the photo grid stays responsive.
      var hashes: [[String: String]] = []
      for asset in assets[batch..<min(batch + 50, assets.count)] where !checkedIDs.contains(asset.id) && !failedIDs.contains(asset.id) {
        if let hash = await Task.detached(priority: .utility, operation: { await Self.checksum(for: asset.id) }).value {
          hashes.append(["id": asset.id, "checksum": hash])
        }
        else { failedIDs.insert(asset.id) } // iCloud-only originals remain unknown.
      }
      guard !hashes.isEmpty else { continue }
      do {
        let response = try await client.send(path: "assets/bulk-upload-check", method: "POST", body: ["assets": hashes])
        guard let results = response["results"] as? [[String: Any]] else { continue }
        let submitted = Set(hashes.compactMap { $0["id"] })
        for result in results {
          guard let id = result["id"] as? String, submitted.contains(id) else { continue }
          if result["action"] as? String == "reject", let serverID = result["assetId"] as? String {
            matchedServerIDs[id] = serverID
          }
          checkedIDs.insert(id)
        }
      } catch { return } // Network/permission errors must not imply "not uploaded".
    }
  }

  nonisolated private static func checksum(for id: String) async -> String? {
    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject,
          let resource = PHAssetResource.assetResources(for: asset).first(where: {
            [.photo, .video, .fullSizePhoto, .fullSizeVideo].contains($0.type)
          }) else { return nil }
    let options = PHAssetResourceRequestOptions()
    options.isNetworkAccessAllowed = false
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

import Combine
import CryptoKit
import Foundation
import Photos
import PhotosUI
import Security
import SwiftUI
import UIKit

@MainActor
private func nativeData(from url: URL, using session: URLSession = .shared) async throws -> (Data, URLResponse) {
  let (data, response) = try await session.data(from: url)
  return (data, response)
}

private func nativeData(for request: URLRequest, using session: URLSession = .shared) async throws -> (Data, URLResponse) {
  let (data, response) = try await session.data(for: request)
  return (data, response)
}

// MARK: - Native session and API

struct NativeServerConfig: Codable {
  var serverUrl: String
  var apiEndpoint: String?
  var accessToken: String?
  var apiKey: String?
  var deviceId: String?
  var userId: String? = nil

  var credential: String? { accessToken ?? apiKey }
}

private enum NativeSessionStore {
  private static let service = "flutter_secure_storage_service"
  private static let legacyService = "com.it_nomads.flutter_secure_storage_service"
  private static let account = "immich.server_config"
  private static let fallbackKey = "flutter.secure_fallback.immich.server_config"
  private static let unprefixedFallbackKey = "secure_fallback.immich.server_config"

  static func read() -> NativeServerConfig? {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    // FlutterSecureStorage stores the key as the generic-password account.
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecSuccess, let data = result as? Data,
       let config = try? JSONDecoder().decode(NativeServerConfig.self, from: data) {
      return config
    }

    // Search known legacy service name and service-less variants as well.
    query[kSecAttrService as String] = legacyService
    result = nil
    if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
       let data = result as? Data,
       let config = try? JSONDecoder().decode(NativeServerConfig.self, from: data) {
      return config
    }
    query.removeValue(forKey: kSecAttrService as String)
    result = nil
    if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
       let data = result as? Data,
       let config = try? JSONDecoder().decode(NativeServerConfig.self, from: data) {
      return config
    }
    // Preserve compatibility with Flutter's documented SharedPreferences
    // fallback used by unsigned iOS builds without Keychain entitlements.
    for key in [fallbackKey, unprefixedFallbackKey] {
      if let raw = UserDefaults.standard.string(forKey: key),
         let data = raw.data(using: .utf8),
         let config = try? JSONDecoder().decode(NativeServerConfig.self, from: data) {
        return config
      }
    }
    // SharedPreferences persists fallback values in a plist dictionary.
    if let preferences = readPreferencesFallback() {
      return try? JSONDecoder().decode(NativeServerConfig.self, from: preferences)
    }
    return nil
  }

  static func save(_ config: NativeServerConfig) throws {
    let data = try JSONEncoder().encode(config)
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    let attributes: [String: Any] = [kSecValueData as String: data]
    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    let writeStatus: OSStatus
    if status == errSecItemNotFound {
      var insert = query
      insert[kSecValueData as String] = data
      writeStatus = SecItemAdd(insert as CFDictionary, nil)
    } else {
      writeStatus = status
    }
    if writeStatus == errSecSuccess {
      UserDefaults.standard.removeObject(forKey: fallbackKey)
      UserDefaults.standard.removeObject(forKey: unprefixedFallbackKey)
    } else {
      // SharedPreferences uses the flutter. prefix for the legacy API.
      UserDefaults.standard.set(String(data: data, encoding: .utf8), forKey: fallbackKey)
    }
  }
}

actor NativeThumbnailDiskCache {
  static let shared = NativeThumbnailDiskCache()
  let directory: URL
  private var writesSincePrune = 0

  private init() {
    directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("ImmichZThumbnails_v2", isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  func diskUsage() -> (count: Int, bytes: Int64) {
    let files = (try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: [.fileSizeKey],
      options: [.skipsHiddenFiles]
    )) ?? []
    var totalBytes: Int64 = 0
    for file in files {
      if let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize {
        totalBytes += Int64(size)
      }
    }
    return (files.count, totalBytes)
  }

  func clearAll() {
    let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])) ?? []
    for file in files {
      try? FileManager.default.removeItem(at: file)
    }
  }

  func data(for key: String) -> Data? {
    try? Data(contentsOf: fileURL(for: key), options: .mappedIfSafe)
  }

  func store(_ data: Data, for key: String) {
    let url = fileURL(for: key)
    try? data.write(to: url, options: .atomic)
    writesSincePrune += 1
    if writesSincePrune >= 128 {
      writesSincePrune = 0
      pruneIfNeeded()
    }
  }

  private func pruneIfNeeded() {
    let files = (try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
      options: [.skipsHiddenFiles]
    )) ?? []
    let entries = files.compactMap { url -> (URL, Int, Date)? in
      guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
            let size = values.fileSize else { return nil }
      return (url, size, values.contentModificationDate ?? .distantPast)
    }
    var total = entries.reduce(0) { $0 + $1.1 }
    guard total > 384 * 1024 * 1024 else { return }
    for (url, size, _) in entries.sorted(by: { $0.2 < $1.2 }) {
      try? FileManager.default.removeItem(at: url)
      total -= size
      if total <= 320 * 1024 * 1024 { break }
    }
  }

  private func fileURL(for key: String) -> URL {
    let digest = SHA256.hash(data: Data(key.utf8)).map { String(format: "%02x", $0) }.joined()
    return directory.appendingPathComponent(digest).appendingPathExtension("thumb")
  }
}

private enum NativeThumbnailPipeline {
  static let networkSession: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.urlCache = nil
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    configuration.httpMaximumConnectionsPerHost = 5
    return URLSession(configuration: configuration)
  }()
}

private enum NativeAPIError: LocalizedError {
  case invalidServer
  case unauthorized
  case http(Int, String)
  case invalidResponse
  case invalidJSON(String)

  var errorDescription: String? {
    switch self {
    case .invalidServer: return "无法连接 Immich 服务器，请检查服务器地址。"
    case .unauthorized: return "认证失败。请检查服务器地址和凭据。"
    case let .http(code, message): return "服务器请求失败（\(code)）：\(message)"
    case .invalidResponse: return "服务器返回了无法识别的数据。"
    case let .invalidJSON(endpoint): return "服务器在 \(endpoint) 返回的数据不是有效 JSON。请检查服务器版本及反向代理的 /api 配置。"
    }
  }
}

// Session-scoped diagnostics for verified matches whose server DTO is not yet
// available in the timeline. Never expose asset IDs or raw server responses.
@MainActor
final class NativeMatchedAssetDiagnostics: ObservableObject {
  @Published private(set) var attempted = 0
  @Published private(set) var loaded = 0
  @Published private(set) var pending = 0
  @Published private(set) var lastAttempt: Date?
  @Published private(set) var lastFailure: Date?
  @Published private(set) var lastFailureCategory: String?
  @Published private(set) var failureCounts: [String: Int] = [:]
  private var failedAssets: [String: String] = [:]

  var unresolvedCount: Int { failedAssets.count }

  func started() {
    attempted += 1
    pending += 1
    lastAttempt = Date()
  }

  func succeeded(id: String) {
    pending = max(0, pending - 1)
    loaded += 1
    failedAssets.removeValue(forKey: id)
    refreshCounts()
  }

  func failed(id: String, error: Error?) {
    pending = max(0, pending - 1)
    let category: String
    if let error = error as? NativeAPIError {
      switch error {
      case .unauthorized: category = "认证失败 (401/403)"
      case let .http(code, _): category = "HTTP \(code)"
      case .invalidJSON: category = "响应 JSON 无效"
      case .invalidResponse: category = "响应格式异常"
      case .invalidServer: category = "服务器地址无效"
      }
    } else if let error = error as? URLError {
      switch error.code {
      case .timedOut: category = "请求超时"
      case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost,
           .cannotFindHost, .dnsLookupFailed: category = "网络连接失败"
      default: category = "网络错误 (\(error.code.rawValue))"
      }
    } else {
      category = error == nil ? "响应缺少有效资产信息" : "其他请求错误"
    }
    failedAssets[id] = category
    lastFailure = Date()
    lastFailureCategory = category
    refreshCounts()
  }

  private func refreshCounts() {
    failureCounts = Dictionary(grouping: failedAssets.values, by: { $0 }).mapValues(\.count)
  }
}

@MainActor
final class NativeImmichClient {
  let config: NativeServerConfig
  private let session: URLSession

  init(config: NativeServerConfig, session: URLSession = .shared) {
    self.config = config
    self.session = session
  }

  nonisolated static func normalize(_ raw: String) -> String {
    var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if !value.hasPrefix("http://") && !value.hasPrefix("https://") { value = "https://" + value }
    while value.hasSuffix("/") { value.removeLast() }
    return value
  }

  static func discover(_ raw: String) async throws -> String {
    let base = normalize(raw)
    guard let url = URL(string: base), url.host != nil else { throw NativeAPIError.invalidServer }
    var candidates = [String]()
    if let wellKnown = URL(string: base + "/.well-known/immich"),
       let (data, response) = try? await nativeData(from: wellKnown),
       (response as? HTTPURLResponse)?.statusCode == 200,
       let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let api = object["api"] as? String, !api.isEmpty {
      candidates.append(api.hasPrefix("http") ? api : base + api)
    }
    candidates.append(contentsOf: [base + "/api", base])
    for candidate in candidates {
      guard let ping = URL(string: candidate + "/server/ping"),
            let (data, response) = try? await nativeData(from: ping),
            (response as? HTTPURLResponse)?.statusCode == 200,
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
      let pong = (object["res"] as? String) == "pong" || (object["res"] as? Bool) == true
      guard pong else { continue }
      return candidate
    }
    throw NativeAPIError.invalidServer
  }

  static func login(server: String, email: String, password: String) async throws -> NativeServerConfig {
    let endpoint = try await discover(server)
    let temporary = NativeImmichClient(config: NativeServerConfig(serverUrl: normalize(server), apiEndpoint: endpoint))
    let result = try await temporary.send(path: "auth/login", method: "POST", body: ["email": email, "password": password])
    guard let token = result["accessToken"] as? String, !token.isEmpty else { throw NativeAPIError.invalidResponse }
    var config = NativeServerConfig(serverUrl: normalize(server), apiEndpoint: endpoint, accessToken: token)
    config.userId = try await NativeImmichClient(config: config).verifiedUserID()
    return config
  }

  static func login(server: String, apiKey: String) async throws -> NativeServerConfig {
    let endpoint = try await discover(server)
    var config = NativeServerConfig(serverUrl: normalize(server), apiEndpoint: endpoint, apiKey: apiKey)
    config.userId = try await NativeImmichClient(config: config).verifiedUserID()
    return config
  }

  func verifiedUserID() async throws -> String {
    let response = try await send(path: "users/me")
    guard let id = response["id"] as? String, !id.isEmpty else { throw NativeAPIError.invalidResponse }
    return id
  }

  func verifySession() async throws {
    _ = try await verifiedUserID()
  }

  func send(path: String, method: String = "GET", query: [URLQueryItem] = [], body: [String: Any]? = nil) async throws -> [String: Any] {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard var components = URLComponents(string: base + "/" + path) else { throw NativeAPIError.invalidServer }
    if !query.isEmpty { components.queryItems = query }
    guard let url = components.url else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    applyAuth(to: &request)
    if let body {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
    }
    let (data, response) = try await nativeData(for: request, using: session)
    guard let http = response as? HTTPURLResponse else { throw NativeAPIError.invalidResponse }
    guard (200..<300).contains(http.statusCode) else {
      if http.statusCode == 401 || http.statusCode == 403 { throw NativeAPIError.unauthorized }
      let message = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["message"] as? String ?? ""
      throw NativeAPIError.http(http.statusCode, message)
    }
    if data.isEmpty { return [:] } // DELETE endpoints may return HTTP 204 No Content.
    do {
      guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw NativeAPIError.invalidJSON(path)
      }
      return object
    } catch let error as NativeAPIError { throw error }
    catch { throw NativeAPIError.invalidJSON(path) }
  }

  func timelineBuckets() async throws -> [NativeBucket] {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard var components = URLComponents(string: base + "/timeline/buckets") else { throw NativeAPIError.invalidServer }
    components.queryItems = [
      URLQueryItem(name: "order", value: "desc"),
      URLQueryItem(name: "orderBy", value: "takenAt"),
      URLQueryItem(name: "visibility", value: "timeline"),
    ]
    guard let url = components.url else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    applyAuth(to: &request)
    let (data, response) = try await nativeData(for: request, using: session)
    try check(response: response, data: data)
    let payload = try parseJSON(data, endpoint: "/timeline/buckets")
    guard let rows = payload as? [[String: Any]] else { throw NativeAPIError.invalidJSON("/timeline/buckets") }
    return rows.compactMap { row in
      guard let id = row["timeBucket"] as? String else { return nil }
      return NativeBucket(id: id, count: row["count"] as? Int ?? 0)
    }
  }

  func assets(in bucket: NativeBucket) async throws -> [NativeAsset] {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard var components = URLComponents(string: base + "/timeline/bucket") else { throw NativeAPIError.invalidServer }
    let bucketParam = bucket.id.count == 10 ? "\(bucket.id)T00:00:00.000Z" : bucket.id
    components.queryItems = [
      URLQueryItem(name: "timeBucket", value: bucketParam),
      URLQueryItem(name: "order", value: "desc"),
      URLQueryItem(name: "orderBy", value: "takenAt"),
      URLQueryItem(name: "visibility", value: "timeline"),
    ]
    guard let url = components.url else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    applyAuth(to: &request)
    let (data, response) = try await nativeData(for: request, using: session)
    try check(response: response, data: data)
    let payload = try parseJSON(data, endpoint: "/timeline/bucket")
    guard let object = payload as? [String: Any], let ids = object["id"] as? [Any] else {
      throw NativeAPIError.invalidJSON("/timeline/bucket")
    }
    func strings(_ key: String) -> [Any] { object[key] as? [Any] ?? [] }
    let dates = strings("fileCreatedAt")
    let created = strings("createdAt")
    let images = strings("isImage")
    let favorites = strings("isFavorite")
    let hashes = strings("thumbhash")
    let livePhotoIDs = strings("livePhotoVideoId")
    let fileNames = strings("originalFileName")
    let mimeTypes = strings("originalMimeType")
    let widths = strings("width")
    let heights = strings("height")
    let sizes = strings("fileSizeInByte")
    let latitudes = strings("latitude")
    let longitudes = strings("longitude")
    let visibility = strings("visibility")
    return ids.enumerated().compactMap { index, rawID in
      guard let id = rawID as? String else { return nil }
      let dateString = (dates[safe: index] as? String) ?? (created[safe: index] as? String) ?? bucket.id
      let date = Self.parseISODate(dateString) ?? Self.parseISODate(bucket.id) ?? .distantPast
      return NativeAsset(
        id: id,
        date: date,
        isImage: images[safe: index] as? Bool ?? true,
        isFavorite: favorites[safe: index] as? Bool ?? false,
        thumbhash: hashes[safe: index] as? String,
        livePhotoVideoId: livePhotoIDs[safe: index] as? String,
        originalFileName: fileNames[safe: index] as? String,
        originalMimeType: mimeTypes[safe: index] as? String,
        width: widths[safe: index] as? Int,
        height: heights[safe: index] as? Int,
        fileSizeInByte: (sizes[safe: index] as? NSNumber)?.int64Value,
        latitude: (latitudes[safe: index] as? NSNumber)?.doubleValue,
        longitude: (longitudes[safe: index] as? NSNumber)?.doubleValue,
        isArchived: (visibility[safe: index] as? String) == "archive" || (visibility[safe: index] as? String) == "ARCHIVE"
      )
    }
  }

  func deleteAsset(id: String) async throws {
    try await deleteAssets(ids: [id])
  }

  func deleteAssets(ids: [String]) async throws {
    guard !ids.isEmpty else { return }
    // Omit `force` so Immich applies its normal trash/recycle-bin semantics.
    _ = try await send(path: "assets", method: "DELETE", body: ["ids": ids])
  }

  func createAlbum(name: String) async throws -> [String: Any] {
    let payload: [String: Any] = [
      "albumName": name
    ]
    return try await send(path: "albums", method: "POST", body: payload)
  }

  func deleteAlbum(id: String) async throws {
    _ = try await send(path: "albums/\(id)", method: "DELETE")
  }

  func updateFavorite(id: String, isFavorite: Bool) async throws {
    try await updateFavorites(ids: [id], isFavorite: isFavorite)
  }

  func updateFavorites(ids: [String], isFavorite: Bool) async throws {
    guard !ids.isEmpty else { return }
    _ = try await send(path: "assets", method: "PUT", body: ["ids": ids, "isFavorite": isFavorite])
  }

  func updateVisibility(ids: [String], visibility: String) async throws {
    guard !ids.isEmpty else { return }
    _ = try await send(path: "assets", method: "PUT", body: ["ids": ids, "visibility": visibility])
  }


  func addAssetsToAlbum(ids: [String], albumID: String) async throws -> [[String: Any]] {
    guard !ids.isEmpty else { return [] }
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard let url = URL(string: base + "/albums/\(albumID)/assets") else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: ["ids": ids])
    applyAuth(to: &request)
    let (data, response) = try await nativeData(for: request, using: session)
    try check(response: response, data: data)
    guard let results = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
      throw NativeAPIError.invalidJSON("/albums/{id}/assets")
    }
    return results
  }

  func assetInfo(id: String) async throws -> [String: Any] {
    try await send(path: "assets/\(id)", method: "GET")
  }

  func serverAsset(id: String) async throws -> NativeAsset? {
    NativeImmichClient.decodeAsset(try await assetInfo(id: id))
  }

  func originalFile(for asset: NativeAsset) async throws -> URL {
    guard let url = originalURL(for: asset),
          let endpoint = URL(string: config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")),
          url.scheme == endpoint.scheme, url.host == endpoint.host, url.port == endpoint.port,
          url.path.hasPrefix(endpoint.path + "/") else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    request.timeoutInterval = 300
    request.setValue("*/*", forHTTPHeaderField: "Accept")
    applyAuth(to: &request)
    let (downloadedURL, response) = try await session.download(for: request)
    try check(response: response, data: Data())
    let suggestedName = asset.originalFileName ?? "immich-\(asset.id).\(asset.isImage ? "jpg" : "mp4")"
    let fileName = URL(fileURLWithPath: suggestedName).lastPathComponent
    let target = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString)-\(fileName)")
    do { try FileManager.default.moveItem(at: downloadedURL, to: target) }
    catch { try? FileManager.default.removeItem(at: downloadedURL); throw error }
    return target
  }

  nonisolated func originalURL(for asset: NativeAsset) -> URL? {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    return URL(string: base + "/assets/\(asset.id)/original")
  }

  nonisolated func thumbnailURL(for asset: NativeAsset, size: String = "preview") -> URL? {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    var components = URLComponents(string: base + "/assets/\(asset.id)/thumbnail")
    components?.queryItems = [URLQueryItem(name: "size", value: size)]
    return components?.url
  }

  func imageData(for url: URL) async throws -> Data {
    try await imageData(for: url, using: session, cacheable: false)
  }

  func thumbnailData(for url: URL) async throws -> Data {
    try await imageData(for: url, using: NativeThumbnailPipeline.networkSession, cacheable: true)
  }

  private func imageData(for url: URL, using imageSession: URLSession, cacheable: Bool) async throws -> Data {
    guard let endpoint = URL(string: config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")),
          url.scheme == endpoint.scheme, url.host == endpoint.host, url.port == endpoint.port,
          url.path.hasPrefix(endpoint.path + "/") else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    request.cachePolicy = cacheable ? .returnCacheDataElseLoad : .useProtocolCachePolicy
    request.setValue("image/*", forHTTPHeaderField: "Accept")
    applyAuth(to: &request)
    let (data, response) = try await nativeData(for: request, using: imageSession)
    try check(response: response, data: data)
    return data
  }

  private func parseJSON(_ data: Data, endpoint: String) throws -> Any {
    do { return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) }
    catch { throw NativeAPIError.invalidJSON(endpoint) }
  }

  private func applyAuth(to request: inout URLRequest) {
    request.setValue(config.deviceId ?? "immichz-ios", forHTTPHeaderField: "x-immich-device-id")
    if let token = config.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
    if let key = config.apiKey { request.setValue(key, forHTTPHeaderField: "x-api-key") }
  }

  private func check(response: URLResponse, data: Data) throws {
    guard let http = response as? HTTPURLResponse else { throw NativeAPIError.invalidResponse }
    guard (200..<300).contains(http.statusCode) else {
      if http.statusCode == 401 || http.statusCode == 403 { throw NativeAPIError.unauthorized }
      throw NativeAPIError.http(http.statusCode, "")
    }
  }

  nonisolated static func parseISODate(_ value: String) -> Date? {
    // Immich metadata normally carries an explicit offset. Some compatible
    // servers send wall-clock timestamps without one; interpret those in the
    // current app/device timezone instead of silently treating them as UTC.
    let hasExplicitZone = value.range(of: #"(?:Z|[+-]\d{2}:?\d{2})$"#, options: .regularExpression) != nil
    if !hasExplicitZone { return parseDate(value) }
    let f1 = ISO8601DateFormatter()
    f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let d = f1.date(from: value) { return d }
    let f2 = ISO8601DateFormatter()
    f2.formatOptions = [.withInternetDateTime]
    if let d = f2.date(from: value) { return d }
    return parseDate(value)
  }

  nonisolated static func formatChineseDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.timeZone = .autoupdatingCurrent
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }

  nonisolated static func formatChineseDate(_ date: Date, includeDay: Bool = true) -> String {
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone = .autoupdatingCurrent
    let currentYear = calendar.component(.year, from: Date())
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    if includeDay {
      if year == currentYear {
        return "\(month)月\(day)日"
      } else {
        return "\(year)年\(month)月\(day)日"
      }
    } else {
      if year == currentYear {
        return "\(month)月"
      } else {
        return "\(year)年\(month)月"
      }
    }
  }

  nonisolated private static func parseDate(_ value: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    // Naive timestamps from compatible Immich servers represent wall-clock
    // time in the device/app timezone; explicit offsets remain authoritative.
    formatter.timeZone = .autoupdatingCurrent
    for format in [
      "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",
      "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
      "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
      "yyyy-MM-dd'T'HH:mm:ss.SSS",
      "yyyy-MM-dd'T'HH:mm:ssXXXXX",
      "yyyy-MM-dd'T'HH:mm:ss",
      "yyyy-MM-dd"
    ] {
      formatter.dateFormat = format
      if let date = formatter.date(from: value) { return date }
    }
    return nil
  }
}

private extension Array {
  subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

struct NativeBucket: Identifiable {
  let id: String
  let count: Int
}

func nativeRefreshedBucketBoundary(old: [NativeBucket], next: Int, refreshed: [NativeBucket]) -> Int {
  guard next > 0 else { return 0 }
  let remainingID = next < old.count ? old[next].id : nil
  let lastLoadedID = next <= old.count ? old[next - 1].id : nil
  if let remainingID, let index = refreshed.firstIndex(where: { $0.id == remainingID }) { return index }
  if let lastLoadedID, let index = refreshed.firstIndex(where: { $0.id == lastLoadedID }) { return index + 1 }
  return min(next, refreshed.count)
}

struct NativeAsset: Identifiable {
  let id: String
  let date: Date
  let isImage: Bool
  let isFavorite: Bool
  let thumbhash: String?
  var livePhotoVideoId: String? = nil
  var originalFileName: String? = nil
  var originalMimeType: String? = nil
  var width: Int? = nil
  var height: Int? = nil
  var fileSizeInByte: Int64? = nil
  var latitude: Double? = nil
  var longitude: Double? = nil
  var isArchived: Bool = false
}

// MARK: - SwiftUI app and login

struct NativeImmichRootView: View {
  let onUseFlutter: () -> Void
  @State private var config: NativeServerConfig?
  @State private var restoring = true
  @State private var restoreError: String?

  var body: some View {
    Group {
      if restoring {
        ProgressView("正在恢复登录状态…")
      } else if let config {
        NativeTabShell(client: NativeImmichClient(config: config), onUseFlutter: onUseFlutter) {
          NativeSyncCacheStore.shared.clear()
          NativeSessionStore.clear()
          self.config = nil
          restoreError = nil
        }
      } else {
        NativeLoginView(error: restoreError, onUseFlutter: onUseFlutter) { config = $0 }
      }
    }
    .task {
      guard restoring else { return }
      if let saved = NativeSessionStore.read(), saved.credential != nil {
        // Restore the verified account's persisted matches before building the
        // photo grid; a legacy session without an ID starts with no matches.
        NativeSyncCacheStore.shared.configure(server: saved.serverUrl, userId: saved.userId)
        do {
          var verified = saved
          verified.userId = try await NativeImmichClient(config: saved).verifiedUserID()
          NativeSyncCacheStore.shared.configure(server: verified.serverUrl, userId: verified.userId)
          try? NativeSessionStore.save(verified)
          config = verified
        } catch {
          if let apiError = error as? NativeAPIError, case .unauthorized = apiError {
            NativeSyncCacheStore.shared.clear()
            NativeSessionStore.clear()
            restoreError = error.localizedDescription
          } else {
            // Keep credentials across offline or transient server failures.
            restoreError = error.localizedDescription
            // Offline restore cannot validate legacy configurations without a
            // user identity; never inherit another account's match cache.
            NativeSyncCacheStore.shared.configure(server: saved.serverUrl, userId: saved.userId)
            config = saved
          }
        }
      }
      restoring = false
    }
  }
}

private extension NativeSessionStore {
  static func clear() {
    let services: [String?] = [service, legacyService, nil]
    for serviceName in services {
      var query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
      ]
      if let serviceName {
        query[kSecAttrService as String] = serviceName
      }
      SecItemDelete(query as CFDictionary)
    }
    UserDefaults.standard.removeObject(forKey: fallbackKey)
    UserDefaults.standard.removeObject(forKey: unprefixedFallbackKey)
  }

  private static func readPreferencesFallback() -> Data? {
    guard let bundleId = Bundle.main.bundleIdentifier,
          let preferencesUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Preferences", isDirectory: true)
            .appendingPathComponent("\(bundleId).plist"),
          let dictionary = NSDictionary(contentsOf: preferencesUrl) as? [String: Any],
          let raw = (dictionary[fallbackKey] ?? dictionary[unprefixedFallbackKey]) as? String else {
      return nil
    }
    return raw.data(using: .utf8)
  }
}

private struct NativeLoginView: View {
  let error: String?
  let onUseFlutter: () -> Void
  let onLogin: (NativeServerConfig) -> Void
  @State private var server = ""
  @State private var email = ""
  @State private var password = ""
  @State private var apiKey = ""
  @State private var useAPIKey = false
  @State private var busy = false
  @State private var loginError: String?

  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("https://immich.example.com", text: $server)
            .textInputAutocapitalization(.never)
            .keyboardType(.URL)
            .autocorrectionDisabled()
          Toggle("使用 API Key 登录", isOn: $useAPIKey)
        } header: { Text("Immich 服务器") }

        Section {
          if useAPIKey {
            SecureField("API Key", text: $apiKey)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          } else {
            TextField("邮箱", text: $email)
              .textInputAutocapitalization(.never)
              .keyboardType(.emailAddress)
              .autocorrectionDisabled()
            SecureField("密码", text: $password)
          }
        } header: { Text("登录凭据") }

        if let message = loginError ?? error {
          Section { Text(message).foregroundColor(.red) }
        }

        Section {
          Button {
            Task { await login() }
          } label: {
            HStack {
              Spacer()
              if busy { ProgressView() } else { Text("登录") }
              Spacer()
            }
          }
          .disabled(busy || server.isEmpty || (useAPIKey ? apiKey.isEmpty : email.isEmpty || password.isEmpty))
        }
      }
      .navigationTitle("Immich")
    }
    .navigationViewStyle(.stack)
  }

  @MainActor private func login() async {
    busy = true
    loginError = nil
    defer { busy = false }
    do {
      let value = useAPIKey
        ? try await NativeImmichClient.login(server: server, apiKey: apiKey)
        : try await NativeImmichClient.login(server: server, email: email, password: password)
      try NativeSessionStore.save(value)
      NativeSyncCacheStore.shared.configure(server: value.serverUrl, userId: value.userId)
      onLogin(value)
    } catch {
      loginError = error.localizedDescription
    }
  }
}

// MARK: - Native Photos timeline

@MainActor
private final class NativeTimelineModel: ObservableObject {
  @Published private(set) var assets: [NativeAsset] = []
  @Published private(set) var isLoading = false
  @Published private(set) var hasOlder = true
  @Published private(set) var newlyAddedCount = 0
  @Published var error: String?

  private let client: NativeImmichClient
  private var buckets: [NativeBucket] = []
  private var nextBucket = 0
  private var searchFallbackEnabled = false
  private var searchCursor: String?
  private let pageSize = 20

  init(client: NativeImmichClient) { self.client = client }

  func loadInitial() async {
    guard !isLoading else { return }
    isLoading = true
    error = nil
    defer { isLoading = false }
    let existingAssets = assets
    let existingIDs = Set(existingAssets.map(\.id))
    let existingBuckets = buckets
    let existingNextBucket = nextBucket
    let existingSearchFallback = searchFallbackEnabled
    let existingSearchCursor = searchCursor
    do {
      let refreshedBuckets = try await client.timelineBuckets()
      searchFallbackEnabled = false
      searchCursor = nil
      buckets = refreshedBuckets
      nextBucket = existingSearchFallback || existingBuckets.isEmpty ? 0 :
        nativeRefreshedBucketBoundary(old: existingBuckets, next: existingNextBucket, refreshed: buckets)
      hasOlder = nextBucket < buckets.count
      // Fetch the newest page while preserving the older pagination boundary.
      for bucket in buckets.prefix(pageSize) {
        let incoming = try await client.assets(in: bucket)
        assets = (assets + incoming).reduce(into: [String: NativeAsset]()) { $0[$1.id] = $1 }.values.sorted { $0.date < $1.date }
      }
      newlyAddedCount = assets.filter { !existingIDs.contains($0.id) }.count
      if existingBuckets.isEmpty {
        nextBucket = min(pageSize, buckets.count)
        hasOlder = nextBucket < buckets.count
        while assets.count < 100 && hasOlder { try await loadNextPage() }
      }
    } catch {
      // Some compatible Immich servers or reverse proxies return a non-JSON
      // timeline response. Keep Photos usable via the standard metadata search.
      do {
        searchFallbackEnabled = true
        searchCursor = nil
        assets = existingAssets
        try await loadSearchFallbackPage()
      } catch {
        assets = existingAssets
        buckets = existingBuckets
        nextBucket = existingNextBucket
        searchFallbackEnabled = existingSearchFallback
        searchCursor = existingSearchCursor
        hasOlder = existingSearchFallback ? existingSearchCursor != nil : existingNextBucket < existingBuckets.count
        self.error = error.localizedDescription
      }
    }
  }

  func refreshLatest() async {
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }
    do {
      if searchFallbackEnabled {
        let page = try await client.searchPage(cursor: nil, filter: ["visibility": ["eq": "timeline"]])
        let existingIDs = Set(assets.map(\.id))
        newlyAddedCount = page.assets.filter { !existingIDs.contains($0.id) }.count
        var seen = Set<String>()
        assets = (page.assets + assets).filter { seen.insert($0.id).inserted }.sorted { $0.date < $1.date }
        // Keep the cursor for the oldest already loaded page. Replacing it
        // with the newest page cursor would replay pages after a refresh.
        if existingIDs.isEmpty { searchCursor = page.next }
        hasOlder = searchCursor != nil
      } else {
        let refreshedBuckets = try await client.timelineBuckets()
        var incoming = [NativeAsset]()
        for bucket in refreshedBuckets.prefix(pageSize) {
          incoming.append(contentsOf: try await client.assets(in: bucket))
        }
        let existingIDs = Set(assets.map(\.id))
        newlyAddedCount = incoming.filter { !existingIDs.contains($0.id) }.count
        var seen = Set<String>()
        assets = (incoming + assets).filter { seen.insert($0.id).inserted }.sorted { $0.date < $1.date }
        let oldBuckets = buckets
        let oldNextBucket = nextBucket
        buckets = refreshedBuckets
        nextBucket = oldBuckets.isEmpty
          ? min(pageSize, buckets.count)
          : nativeRefreshedBucketBoundary(old: oldBuckets, next: oldNextBucket, refreshed: buckets)
        hasOlder = nextBucket < buckets.count
      }
      error = nil
    } catch {
      // Keep the already loaded timeline visible if foreground refresh fails.
      self.error = error.localizedDescription
    }
  }


  func loadOlder() async {
    guard !isLoading, hasOlder else { return }
    isLoading = true
    defer { isLoading = false }
    do {
      error = nil
      if searchFallbackEnabled { try await loadSearchFallbackPage() }
      else { try await loadNextPage() }
    } catch { self.error = error.localizedDescription }
  }

  func retry() async {
    if hasOlder { await loadOlder() }
    else if error != nil { await loadInitial() }
  }

  private func loadSearchFallbackPage() async throws {
    let page = try await client.searchPage(cursor: searchCursor, filter: ["visibility": ["eq": "timeline"]])
    var seen = Set(assets.map(\.id))
    assets = (assets + page.assets).filter { seen.insert($0.id).inserted }.sorted { $0.date < $1.date }
    searchCursor = page.next
    hasOlder = page.next != nil
    error = nil
  }

  private func loadNextPage() async throws {
    guard nextBucket < buckets.count else { hasOlder = false; return }
    let end = min(nextBucket + pageSize, buckets.count)
    let page = buckets[nextBucket..<end]
    var result: [NativeAsset] = []
    for bucket in page {
      let bucketAssets = try await client.assets(in: bucket)
      result.append(contentsOf: bucketAssets)
    }
    nextBucket = end
    hasOlder = nextBucket < buckets.count
    var seen = Set<String>()
    assets = (assets + result).filter { seen.insert($0.id).inserted }.sorted { $0.date < $1.date }
  }

  func removeAssets(ids: Set<String>) {
    assets.removeAll { ids.contains($0.id) }
  }

  func upsert(_ asset: NativeAsset) {
    assets.removeAll { $0.id == asset.id }
    assets.append(asset)
    assets.sort { $0.date < $1.date }
  }

  func acknowledgeNewAssets() { newlyAddedCount = 0 }
}

struct NativePhotosView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  let onUseFlutter: () -> Void
  let onLogout: () -> Void
  let matchedAssetDiagnostics: NativeMatchedAssetDiagnostics
  @StateObject private var model: NativeTimelineModel
  @StateObject private var cloud = NativeCloudStatus()
  @State private var columns: Int = 4
  @State private var gestureBaseColumns: Int? = nil
  @State private var gestureAnchorID: String?
  @State private var loadingMatchedServerIDs = Set<String>()
  @State private var sourceFilter: NativePhotosSource = .all
  @State private var cachedDayGroups: [NativeDayGroup] = []
  @State private var cachedFirstGroupDatesInMonth = Set<Date>()
  @AppStorage("immichz_photos_excluded_local_album_ids") private var excludedLocalAlbumIDsRaw = "[]"
  @AppStorage("immichz_photos_excluded_server_album_ids") private var excludedServerAlbumIDsRaw = "[]"
  @State private var excludedServerAssetIDs = Set<String>()
  @State private var activeViewerItem: NativeGridItem?
  @State private var selectedIDs: Set<String> = []
  @State private var isSelecting = false
  @State private var isDragSelecting = false
  @State private var dragSelectionIntent: NativeDragSelectionIntent = .undecided
  @State private var isMagnifying = false
  @State private var dragInitialSelectedIDs: Set<String> = []
  @State private var dragSelectMode: Bool = true // true = selecting, false = deselecting
  @State private var dragStartLocation: CGPoint? = nil
  @State private var dragStartAssetID: String? = nil
  @State private var itemBounds: [String: CGRect] = [:]
  @State private var lastPublishedItemBounds: [String: CGRect] = [:]
  @State private var lastItemBoundsUpdate: Date = .distantPast
  @State private var pendingSourceChangeScroll = false
  @State private var hasInitialScrolled = false
  @State private var initialRemoteLoaded = false
  @State private var lastForegroundRefreshTime: Date = .distantPast
  @State private var needsForegroundRefresh = false
  @State private var didInitialPosition = false
  @State private var initialScrollVisible = false
  @State private var loadingOlderAnchor: String?
  @State private var showServerSettings = false
  @State private var showSyncSettings = false
  @State private var showDeleteConfirmation = false
  @State private var showLocalDeleteWarning = false
  @State private var pendingDeleteScope: NativeDeleteTargetScope = .all
  @State private var deletionError: String?
  @State private var isDeleting = false
  @State private var batchShareItems: [Any]? = nil
  @State private var isPreparingBatchShare = false
  @State private var isRefreshing = false
  @State private var actionMessage: String?
  @State private var archivedServerIDs = Set<String>()
  @State private var showSaveConfirmation = false
  @State private var showAlbumTargetDialog = false
  @State private var showLocalAlbumPicker = false
  @State private var showServerAlbumPicker = false
  @State private var duplicateSaveCount = 0
  @State private var lastScrollToBottomTime: Date = .distantPast
  private let bottomAnchor = "timeline-bottom-anchor"

  init(client: NativeImmichClient, device: NativeDeviceLibrary, onUseFlutter: @escaping () -> Void, onLogout: @escaping () -> Void, matchedAssetDiagnostics: NativeMatchedAssetDiagnostics) {
    self.client = client
    self.device = device
    self.onUseFlutter = onUseFlutter
    self.onLogout = onLogout
    self.matchedAssetDiagnostics = matchedAssetDiagnostics
    _model = StateObject(wrappedValue: NativeTimelineModel(client: client))
  }

  private var totalDisplayCount: Int {
    cachedDayGroups.reduce(0) { $0 + $1.assets.count }
  }



  private var filteredTimelineAssets: [NativeGridItem] {
    let matched = cloud.matchedServerIDs
    let serverByID = Dictionary(model.assets.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    let serverToLocal = Dictionary(matched.map { ($0.value, $0.key) }, uniquingKeysWith: { first, _ in first })
    let localByID = Dictionary(device.assets.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    let excludedLocalIDs = excludedLocalAssetIDs(for: nativePhotosExcludedAlbumIDs(from: excludedLocalAlbumIDsRaw))
    var seenServer = Set<String>()
    var result = [NativeGridItem]()
    for local in device.assets {
      let item: NativeGridItem
      if let serverID = matched[local.id] {
        if let server = serverByID[serverID] {
          item = NativeGridItem(server: server, local: local)
        } else {
          // Verified cloud membership must remain visible in the cloud filter.
          // Without the DTO, server-side actions remain unavailable until hydration.
          item = NativeGridItem(server: nil, local: local)
        }
        seenServer.insert(serverID)
        if excludedServerAssetIDs.contains(serverID) { continue }
        if sourceFilter == .server && archivedServerIDs.contains(serverID) { continue }
      } else { item = NativeGridItem(server: nil, local: local) }
      if nativePhotosSourceIncludes(sourceFilter, hasLocal: item.local != nil, hasServer: item.server != nil, hasVerifiedMatch: matched[local.id] != nil),
         !excludedLocalIDs.contains(local.id) {
        result.append(item)
      }
    }
    if sourceFilter != .device {
      for server in model.assets where !seenServer.contains(server.id) && !archivedServerIDs.contains(server.id) {
        if excludedServerAssetIDs.contains(server.id) { continue }
        if let localID = serverToLocal[server.id], excludedLocalIDs.contains(localID) { continue }
        let local = serverToLocal[server.id].flatMap { localByID[$0] }
        result.append(NativeGridItem(server: server, local: local))
      }
    }
    return result.sorted { lhs, rhs in
      if lhs.date == rhs.date { return lhs.id < rhs.id }
      return lhs.date < rhs.date
    }
  }

  private func excludedLocalAssetIDs(for albumIDs: Set<String>) -> Set<String> {
    nativePhotosHiddenLocalAssetIDs(
      in: device.albums,
      excludedAlbumIDs: albumIDs,
      assetsForAlbum: device.assets(in:)
    )
  }

  private var connectionAndSyncBadge: some View {
    HStack(spacing: 4) {
      // 1. 服务器连接状态指示（使用柔和中性色 / secondary，风格协调）
      if model.error != nil {
        Image(systemName: "bolt.slash")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary.opacity(0.6))
      } else if model.isLoading {
        Image(systemName: "antenna.radiowaves.left.and.right")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary)
      } else {
        Image(systemName: "server.rack")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary)
      }

      // 2. 同步状态指示
      if cloud.isRunning {
        Image(systemName: "arrow.clockwise.icloud")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary)
      } else if unknownLocalCount > 0 {
        Image(systemName: "questionmark.icloud")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary)
      } else if unsyncedLocalCount > 0 {
        Image(systemName: "icloud.slash")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary.opacity(0.6))
      } else {
        Image(systemName: "checkmark.icloud")
          .font(.system(size: 11, weight: .medium))
          .foregroundColor(.secondary)
      }
    }
  }

  private var unsyncedLocalCount: Int {
    device.assets.filter { cloud.checkedIDs.contains($0.id) && !cloud.failedVerificationIDs.contains($0.id) && cloud.matchedServerIDs[$0.id] == nil }.count
  }

  private var unknownLocalCount: Int {
    device.assets.filter { (!cloud.checkedIDs.contains($0.id) || cloud.failedVerificationIDs.contains($0.id)) && cloud.matchedServerIDs[$0.id] == nil }.count
  }

  @ViewBuilder
  private var trailingToolbarContent: some View {
    if isSelecting {
      Button(selectedIDs.count == totalDisplayCount ? "取消全选" : "全选") {
        if selectedIDs.count == totalDisplayCount { selectedIDs.removeAll() }
        else { selectedIDs = Set(cachedDayGroups.flatMap(\.assets).map(\.id)) }
      }
    } else {
      HStack(spacing: 2) {
        Button("选择") {
          isSelecting = true
          selectedIDs.removeAll()
        }
        .font(.system(size: 14, weight: .medium))
        .buttonStyle(.plain)
        .padding(.horizontal, 5)

        Button {
          showServerSettings = true
        } label: {
          serverStatusIcon
        }
        .frame(width: 36, height: 40)
        .buttonStyle(.plain)

        Button {
          showSyncSettings = true
        } label: {
          cloudSyncStatusIcon
        }
        .frame(width: 36, height: 40)
        .buttonStyle(.plain)
      }
      .fixedSize(horizontal: true, vertical: false)
    }
  }

  @ViewBuilder
  private var serverStatusIcon: some View {
    if model.error != nil {
      Image(systemName: "bolt.slash")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary.opacity(0.6))
    } else if model.isLoading {
      Image(systemName: "antenna.radiowaves.left.and.right")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    } else {
      Image(systemName: "server.rack")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    }
  }

  @ViewBuilder
  private var cloudSyncStatusIcon: some View {
    if model.error != nil || cloud.failedCount > 0 {
      Image(systemName: "xmark.icloud")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    } else if cloud.isRunning {
      Image(systemName: "arrow.clockwise.icloud")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    } else if unknownLocalCount > 0 {
      Image(systemName: "questionmark.icloud")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    } else if unsyncedLocalCount > 0 {
      Image(systemName: "icloud.slash")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary.opacity(0.6))
    } else {
      Image(systemName: "checkmark.icloud")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
    }
  }

  private func formatDateBadge(for group: NativeDayGroup) -> String {
    let isFirstInMonth = cachedFirstGroupDatesInMonth.contains(group.date)
    return NativeImmichClient.formatChineseDate(group.date, includeDay: !isFirstInMonth)
  }

  @ViewBuilder
  private func newPhotosBanner(proxy: ScrollViewProxy) -> some View {
    if model.newlyAddedCount > 0 && sourceFilter != .device {
      Button {
        model.acknowledgeNewAssets()
        scrollToBottom(proxy: proxy, animated: true)
      } label: {
        Text("有 \(model.newlyAddedCount) 项新照片 · 查看最新")
          .font(.caption.weight(.medium))
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(.thinMaterial, in: Capsule())
      }
      .padding(.horizontal)
      .buttonStyle(.plain)
    }
  }

  private func timelineGridContent(proxy: ScrollViewProxy) -> some View {
          LazyVStack(spacing: 4) {
            newPhotosBanner(proxy: proxy)
            if sourceFilter != .device && model.hasOlder && !model.assets.isEmpty {
              ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .id("older-loader")
                .onAppear {
                  if didInitialPosition {
                    requestOlder(proxy: proxy)
                  }
                }
            }
            if sourceFilter != .device && model.assets.isEmpty && (model.isLoading || device.isLoading) {
              VStack(spacing: 10) {
                ProgressView()
                Text("正在加载照片…")
                  .font(.caption).foregroundColor(.secondary)
              }
              .frame(maxWidth: .infinity, minHeight: 240)
            }
            if !model.isLoading && !device.isLoading && model.error == nil &&
                cachedDayGroups.isEmpty && (sourceFilter == .device ? (!device.authorized || device.assets.isEmpty) : (model.assets.isEmpty && device.assets.isEmpty)) {
              VStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                  .font(.largeTitle).foregroundColor(.secondary)
                Text("暂无照片").font(.headline)
                Text(sourceFilter == .device && !device.authorized ? "请授予照片访问权限，查看本机照片。" : "当前来源中没有可显示的照片。")
                  .font(.caption).foregroundColor(.secondary)
              }
              .frame(maxWidth: .infinity, minHeight: 220)
            }
            ForEach(cachedDayGroups, id: \.date) { group in
              VStack(alignment: .leading, spacing: 2) {
                if columns > 6 {
                  Text(formatDateBadge(for: group))
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                }
                let gridSpacing: CGFloat = columns > 7 ? 1 : 2
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columns), spacing: gridSpacing) {
                  ForEach(group.assets) { entry in
                    Color.clear
                      .aspectRatio(1, contentMode: .fit)
                      .overlay(
                        GeometryReader { geo in
                          Group {
                            if let asset = entry.server { NativeThumbnail(client: client, asset: asset, columns: columns) }
                            else if let asset = entry.local { NativeDeviceThumbnail(asset: asset, columns: columns) }
                          }
                          .frame(width: geo.size.width, height: geo.size.height)
                          .clipped()
                          .preference(
                            key: NativeItemFramePreferenceKey.self,
                            value: nativePhotoFramePreference(
                              id: entry.id,
                              frame: geo.frame(in: .named("photosScrollSpace")),
                              viewportHeight: UIScreen.main.bounds.height
                            )
                          )
                        }
                      )
                      .clipped()
                      .overlay(alignment: .topLeading) {
                        if columns <= 6 && entry.id == group.assets.first?.id {
                          Text(formatDateBadge(for: group))
                            .font(.system(size: max(9, 13 - CGFloat(columns)), weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.65))
                            .cornerRadius(3)
                            .allowsHitTesting(false)
                        }
                      }
                      .overlay(alignment: .bottomLeading) {
                        if entry.isVideo && columns <= 7 {
                          Image(systemName: "play.fill")
                            .font(.system(size: columns > 4 ? 7 : 11, weight: .bold))
                            .foregroundColor(.white).shadow(color: .black, radius: 2)
                            .padding(columns > 4 ? 1.5 : 3)
                        }
                      }
                      .overlay(alignment: .bottomTrailing) {
                        if columns <= 7 {
                          Image(systemName: cloudSymbol(for: entry))
                            .font(.system(size: columns > 4 ? 7 : 13, weight: .semibold))
                            .foregroundColor(.white).shadow(color: .black, radius: 2)
                            .padding(columns > 4 ? 1.5 : 3)
                        }
                      }
                      .overlay(alignment: .topTrailing) {
                        if selectedIDs.contains(entry.id) {
                          Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: columns > 7 ? 12 : (columns > 4 ? 16 : 20), weight: .semibold))
                            .foregroundStyle(.white, .blue)
                            .padding(columns > 7 ? 1 : 4)
                        }
                      }
                      .contentShape(Rectangle())
                      .accessibilityLabel("\(entry.date.formatted()), \(cloudDescription(for: entry))")
                      .onTapGesture {
                        guard !isMagnifying else { return }
                        if isSelecting {
                          toggleSelection(entry.id)
                        } else {
                          activeViewerItem = entry
                        }
                      }
                      .onLongPressGesture(minimumDuration: 0.28, maximumDistance: 15) {
                        guard !isMagnifying else { return }
                        if !isSelecting {
                          enterSelection(startingWith: entry.id)
                        } else {
                          startDragSelectionInSelectMode(startingWith: entry.id)
                        }
                      }
                      .id(entry.id)
                  }
                }
              }
            }
            Color.clear.frame(height: 1).id(bottomAnchor)
          }
          .opacity(initialScrollVisible ? 1 : 0)
  }

  private func timelineGestureContent<Content: View>(_ content: Content, proxy: ScrollViewProxy) -> some View {
    content
        .coordinateSpace(name: "photosScrollSpace")
        .nativeScrollDisabled(isDragSelecting)
        .onPreferenceChange(NativeItemFramePreferenceKey.self) { frames in
          let forceUpdate = isSelecting || isDragSelecting || isMagnifying
          let now = Date()
          // Geometry preferences are emitted continuously while scrolling. Publish
          // ordinary viewport changes at a lower rate to avoid invalidating the
          // whole timeline several times per second; selection/zoom stays live.
          guard forceUpdate || now.timeIntervalSince(lastItemBoundsUpdate) >= 0.25 else { return }
          guard nativeShouldRefreshPhotoFrames(
            previous: lastPublishedItemBounds,
            next: frames,
            force: forceUpdate
          ) else { return }
          lastItemBoundsUpdate = now
          lastPublishedItemBounds = frames
          itemBounds = frames
        }
        .simultaneousGesture(
          DragGesture(minimumDistance: 4, coordinateSpace: .named("photosScrollSpace"))
            .onChanged { drag in
              guard isSelecting, !isMagnifying else { return }
              if dragSelectionIntent == .undecided {
                let intent = nativeDragSelectionIntent(for: drag.translation)
                if intent != .undecided { dragSelectionIntent = intent }
              }
              guard dragSelectionIntent == .select else { return }
              if !isDragSelecting {
                guard let hitID = itemBounds.first(where: { $0.value.contains(drag.startLocation) })?.key else { return }
                isDragSelecting = true
                startDragSelectionInSelectMode(startingWith: hitID, at: drag.startLocation)
              }
              handle2DDragSelection(at: drag.location)
            }
            .onEnded { _ in
              isDragSelecting = false
              dragSelectionIntent = .undecided
              finishDragSelection()
            }
        )
        .background(Color(uiColor: .systemBackground))
        .simultaneousGesture(
          MagnificationGesture()
            .onChanged { value in
              guard !isSelecting else { return }
              isMagnifying = true
              let base = gestureBaseColumns ?? columns
              if gestureBaseColumns == nil {
                gestureBaseColumns = base
                gestureAnchorID = centerVisibleAssetID
              }
              let deadzone = 0.12
              let effectiveValue: CGFloat
              if value > 1 {
                guard value >= 1 + deadzone else { return }
                effectiveValue = value - deadzone
              } else {
                guard value <= 1 - deadzone else { return }
                effectiveValue = value + deadzone
              }
              let delta = effectiveValue >= 1
                ? -(effectiveValue - 1) * 4
                : (1 / max(0.08, effectiveValue) - 1) * 4
              let target = min(15, max(2, Int((CGFloat(base) + delta).rounded())))
              guard target != columns else { return }
              UIImpactFeedbackGenerator(style: .medium).impactOccurred()
              columns = target
              if let anchor = gestureAnchorID { withAnimation(.none) { proxy.scrollTo(anchor, anchor: .center) } }
            }
            .onEnded { _ in
              gestureBaseColumns = nil
              gestureAnchorID = nil
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isMagnifying = false }
            }
        )
  }

  private func timelineLifecycleContent<Content: View>(_ content: Content, proxy: ScrollViewProxy) -> some View {
    content
        .onChange(of: cloud.matchedServerIDs) { _ in
          let anchor = visibleAnchorID
          rebuildDayGroups()
          // Don't let background match hydration override the in-flight initial
          // scroll-to-latest sequence.
          if didInitialPosition, !pendingSourceChangeScroll, let anchor { withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) } }
          Task { await loadKnownMatchedServerAssets() }
        }
        .onChange(of: sourceFilter) { _ in
          actionMessage = nil
          rebuildDayGroups()
          updateSelectionAfterTimelineChange()
          positionAtLatestAfterSourceChange(proxy: proxy)
        }
        .refreshable {
          let anchor = visibleAnchorID
          await model.refreshLatest()
          await device.refreshAndWait()
          rebuildDayGroups()
          await cloud.check(device.assets, client: client)
          await loadKnownMatchedServerAssets()
          if let anchor { withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) } }
        }
        .onChange(of: device.assets.count) { _ in
          rebuildDayGroups()
          Task { await cloud.check(device.assets, client: client) }
          positionInitiallyIfReady(proxy: proxy)
          if pendingSourceChangeScroll { positionAtLatestAfterSourceChange(proxy: proxy) }
        }
        .onChange(of: excludedLocalAlbumIDsRaw) { _ in
          rebuildDayGroups()
          updateSelectionAfterTimelineChange()
        }
        .onChange(of: excludedServerAlbumIDsRaw) { _ in
          refreshExcludedServerAssetIDs()
          updateSelectionAfterTimelineChange()
        }
        .onChange(of: device.isLoading) { loading in
          guard !loading else { return }
          rebuildDayGroups()
          if !hasInitialScrolled { positionInitiallyIfReady(proxy: proxy) }
          if pendingSourceChangeScroll { positionAtLatestAfterSourceChange(proxy: proxy) }
        }
        .onAppear {
          rebuildDayGroups()
          refreshExcludedServerAssetIDs()
          if model.assets.isEmpty && !model.isLoading {
            Task {
              await model.loadInitial()
              initialRemoteLoaded = true
              rebuildDayGroups()
              positionInitiallyIfReady(proxy: proxy)
              await cloud.check(device.assets, client: client)
              await loadKnownMatchedServerAssets()
            }
          } else {
            initialRemoteLoaded = true
            Task {
              await cloud.check(device.assets, client: client)
              await loadKnownMatchedServerAssets()
            }
            positionInitiallyIfReady(proxy: proxy)
          }
        }
        .onChange(of: model.assets.count) { _ in
          let anchor = visibleAnchorID
          rebuildDayGroups()
          updateSelectionAfterTimelineChange()
          if !hasInitialScrolled { positionInitiallyIfReady(proxy: proxy) }
          else if didInitialPosition, !pendingSourceChangeScroll, let anchor { withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) } }
          if pendingSourceChangeScroll { positionAtLatestAfterSourceChange(proxy: proxy) }
        }
        .onChange(of: model.isLoading) { loading in
          if !loading { positionInitiallyIfReady(proxy: proxy) }
          if pendingSourceChangeScroll { positionAtLatestAfterSourceChange(proxy: proxy) }
        }
        .onReceive(NotificationCenter.default.publisher(for: .immichScrollPhotosToBottom)) { _ in
          let now = Date()
          guard now.timeIntervalSince(lastScrollToBottomTime) > 0.25 else { return }
          lastScrollToBottomTime = now
          if hasInitialScrolled { scrollToBottom(proxy: proxy, animated: true) }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
          needsForegroundRefresh = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
          guard needsForegroundRefresh, !isSelecting else { return }
          needsForegroundRefresh = false
          let now = Date()
          guard now.timeIntervalSince(lastForegroundRefreshTime) > 2 else { return }
          lastForegroundRefreshTime = now
          Task {
            let anchor = visibleAnchorID
            await device.refreshAndWait()
            if !model.isLoading { await model.refreshLatest() }
            rebuildDayGroups()
            updateSelectionAfterTimelineChange()
            initialRemoteLoaded = true
            await cloud.check(device.assets, client: client)
            await loadKnownMatchedServerAssets()
            if let anchor { withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) } }
          }
        }
  }

  private func timelineChromeContent<Content: View>(_ content: Content, proxy: ScrollViewProxy) -> some View {
    content
        .safeAreaInset(edge: .bottom, spacing: 0) {
          if isSelecting {
            HStack(spacing: 0) {
              batchActionButton("square.and.arrow.up", label: "分享", disabled: selectedIDs.isEmpty || isPreparingBatchShare) { triggerBatchShare() }
              batchActionButton("heart", label: "收藏", disabled: selectedIDs.isEmpty) { Task { await updateBatchFavorites() } }
              batchActionButton("archivebox", label: "归档", disabled: !selectedItems.contains(where: { $0.server != nil })) { Task { await archiveSelected() } }
              batchActionButton("plus.rectangle.on.folder", label: "加入相册", disabled: !selectedItems.contains(where: { $0.server != nil || $0.local != nil })) { showAlbumTargetDialog = true }
              batchActionButton("square.and.arrow.down", label: "保存", disabled: !selectedItems.contains(where: { $0.server != nil })) { prepareSaveToDevice() }
              batchActionButton("trash", label: "删除", disabled: selectedIDs.isEmpty || isDeleting, destructive: true) { showDeleteConfirmation = true }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
          } else {
            if !device.authorized && sourceFilter != .server {
              Button("允许访问本机照片（可选）") { Task { await device.requestAccess() } }.padding(6)
            }
            if let message = actionMessage {
              HStack(spacing: 8) {
                Text(message).font(.caption).lineLimit(3)
                Spacer(minLength: 4)
                Button { actionMessage = nil } label: {
                  Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("关闭操作提示")
              }
              .padding(6)
            }
            if let message = cloud.message {
              HStack(spacing: 8) {
                Text(message).font(.caption).lineLimit(3)
                Spacer(minLength: 4)
                Button("重试核验") { Task { await cloud.retry(device.assets, client: client) } }
                  .font(.caption).fixedSize()
              }
              .padding(6)
            }
            if let message = model.error {
              HStack { Text(message).font(.caption).lineLimit(2); Button("重试") { Task { await model.retry() } } }.padding(6)
            }
          }
        }
        .navigationTitle("照片")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if isSelecting {
              Button("取消") { clearSelection() }
            } else {
              HStack(spacing: 8) {
                Button {
                  triggerRefresh(proxy: proxy)
                } label: {
                  if isRefreshing || model.isLoading {
                    ProgressView()
                      .scaleEffect(0.7)
                      .frame(width: 16, height: 16)
                  } else {
                    Image(systemName: "arrow.clockwise")
                      .font(.system(size: 14, weight: .medium))
                      .foregroundColor(.secondary)
                  }
                }
                .buttonStyle(.plain)

                Text("\(totalDisplayCount) 项")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
          }
          ToolbarItem(placement: .principal) {
            if isSelecting {
              Text("已选 \(selectedIDs.count) 项").font(.headline)
            } else {
              Picker("照片来源", selection: $sourceFilter) {
                ForEach(NativePhotosSource.allCases) { source in Text(source.rawValue).tag(source) }
              }
              .pickerStyle(.segmented)
              .frame(maxWidth: 230)
              .accessibilityLabel("照片来源")
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            trailingToolbarContent
          }
        }
  }

  private func timelineModalContent<Content: View>(_ content: Content) -> some View {
    content
        .confirmationDialog("选择相册来源", isPresented: $showAlbumTargetDialog, titleVisibility: .visible) {
          Button("加入本机相册") { showLocalAlbumPicker = true }
          Button("加入云端相册") { showServerAlbumPicker = true }
          Button("取消", role: .cancel) {}
        } message: { Text("本机资产和云端资产分别操作，不会自动上传。") }
        .confirmationDialog("删除选中的 \(selectedIDs.count) 项照片", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
          if selectionSpansBothSources {
            Button("删除所有所选副本", role: .destructive) { Task { await deleteSelectedPhotos(scope: .all) } }
          }
          if selectedItems.contains(where: { $0.local != nil }) {
            Button("仅删除本机副本", role: .destructive) { Task { await deleteSelectedPhotos(scope: .localOnly) } }
          }
          if selectedItems.contains(where: { $0.server != nil }) {
            Button("仅删除云端副本", role: .destructive) { Task { await deleteSelectedPhotos(scope: .remoteOnly) } }
          }
          Button("取消", role: .cancel) {}
        } message: {
          Text("所选内容中本机 \(nativePhotosSelectionActionAvailability(selectedItems).local) 项、云端 \(nativePhotosSelectionActionAvailability(selectedItems).server) 项；不在指定来源的项目将跳过。仅删除云端而保留本机时，若自动备份开启，照片可能再次上传。请明确选择删除范围；本机删除也可能同步至 iCloud 设备。")
        }
        .alert("保存到本机照片", isPresented: $showSaveConfirmation) {
          Button("取消", role: .cancel) {}
          Button("继续保存") { Task { await saveSelectedToDevice() } }
        } message: {
          Text(duplicateSaveCount > 0 ? "所选内容中有 \(duplicateSaveCount) 项已存在本机副本，继续操作可能产生重复照片。" : "将下载云端原件并保存到系统照片。")
        }
        .alert("本机删除确认", isPresented: $showLocalDeleteWarning) {
          Button("取消", role: .cancel) {}
          Button("继续", role: .destructive) {
            let targets = selectedItems
            let scope = pendingDeleteScope
            Task { await performSelectedDeletion(items: targets, scope: scope) }
          }
        } message: { Text("删除本机照片会永久从系统照片中移除；若开启 iCloud 照片，可能同步到其他设备。将仅执行你刚才选择的删除范围。") }
        .alert("删除失败", isPresented: Binding(get: { deletionError != nil }, set: { if !$0 { deletionError = nil } })) {
          Button("确定", role: .cancel) { deletionError = nil }
        } message: { Text(deletionError ?? "未知错误") }
        .sheet(item: Binding<NativeSharePayload?>(
          get: { batchShareItems.map { NativeSharePayload(contents: $0) } },
          set: { if $0 == nil { batchShareItems = nil } }
        )) { payload in
          NativeActivityView(activityItems: payload.content)
        }
        .sheet(isPresented: $showServerSettings) {
          NativeServerSettingsSheet(client: client, onLogout: onLogout)
        }
        .sheet(isPresented: $showSyncSettings) {
          NativeSyncSettingsSheet(client: client, device: device, cloud: cloud)
        }
        .sheet(isPresented: $showLocalAlbumPicker) {
          NativePhotosLocalAlbumPicker(albums: device.albums) { albumID in Task { await addSelectedToLocalAlbum(albumID) } }
        }
        .sheet(isPresented: $showServerAlbumPicker) {
          NativePhotosServerAlbumPicker(client: client) { albumID in Task { await addSelectedToServerAlbum(albumID) } }
        }
        .fullScreenCover(item: $activeViewerItem) { item in
          NativeUnifiedGalleryViewer(
            client: client,
            device: device,
            items: cachedDayGroups.flatMap(\.assets),
            initialItem: item,
            onDeleteItem: { deletedItem, scope in
              if scope == .all || scope == .remoteOnly {
                if let sid = deletedItem.server?.id { model.removeAssets(ids: [sid]) }
                if let local = deletedItem.local,
                   NativeSyncCacheStore.shared.serverID(for: local.id) == deletedItem.server?.id {
                  cloud.forgetMatches(localIDs: Set([local.id]))
                }
              }
              device.refresh()
              rebuildDayGroups()
            },
            onServerAssetUpdated: { model.upsert($0) },
            onServerAssetArchived: { model.removeAssets(ids: [$0]) }
          )
        }
  }

  var body: some View {
    NavigationView {
      ScrollViewReader { proxy in
        timelineModalContent(
          timelineChromeContent(
            timelineLifecycleContent(
              timelineGestureContent(ScrollView { timelineGridContent(proxy: proxy) }, proxy: proxy),
              proxy: proxy
            ),
            proxy: proxy
          )
        )
      }
    }
    .navigationViewStyle(.stack)
  }

  private var selectedItems: [NativeGridItem] {
    cachedDayGroups.flatMap(\.assets).filter { selectedIDs.contains($0.id) }
  }

  private var visibleAnchorID: String? {
    let viewportHeight = UIScreen.main.bounds.height
    return itemBounds.filter { $0.value.maxY > 0 && $0.value.minY < viewportHeight }
      .min(by: { $0.value.minY < $1.value.minY })?.key
  }

  private var centerVisibleAssetID: String? {
    let viewport = UIScreen.main.bounds
    let center = CGPoint(x: viewport.midX, y: viewport.midY)
    return itemBounds.filter { $0.value.maxY > 0 && $0.value.minY < viewport.height }
      .min(by: { hypot($0.value.midX - center.x, $0.value.midY - center.y) < hypot($1.value.midX - center.x, $1.value.midY - center.y) })?.key
  }

  @MainActor private func loadKnownMatchedServerAssets() async {
    let loaded = Set(model.assets.map(\.id))
    let missing = Set(cloud.matchedServerIDs.values).filter { !loaded.contains($0) && !loadingMatchedServerIDs.contains($0) }
    guard !missing.isEmpty else { return }
    loadingMatchedServerIDs.formUnion(missing)
    for id in missing {
      matchedAssetDiagnostics.started()
      do {
        if let asset = try await client.serverAsset(id: id) {
          model.upsert(asset)
          matchedAssetDiagnostics.succeeded(id: id)
        } else {
          matchedAssetDiagnostics.failed(id: id, error: nil)
        }
      } catch {
        matchedAssetDiagnostics.failed(id: id, error: error)
      }
      loadingMatchedServerIDs.remove(id)
    }
    if matchedAssetDiagnostics.unresolvedCount > 0 {
      actionMessage = "有 \(matchedAssetDiagnostics.unresolvedCount) 项已匹配的云端资产详情暂时无法载入；可在设置的 Debug 页面查看原因，刷新后重试。"
    } else if actionMessage?.contains("已匹配的云端资产详情暂时无法载入") == true {
      actionMessage = nil
    }
  }

  private func batchActionButton(_ symbol: String, label: String, disabled: Bool, destructive: Bool = false, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      VStack(spacing: 3) {
        Image(systemName: symbol).font(.system(size: 18, weight: .medium))
        Text(label).font(.system(size: 10, weight: .medium))
      }
      .foregroundColor(disabled ? .secondary : (destructive ? .red : .primary))
      .frame(maxWidth: .infinity, minHeight: 42)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(disabled)
    .accessibilityLabel(label)
  }

  private var selectionSpansBothSources: Bool {
    selectedItems.contains(where: { $0.local != nil }) && selectedItems.contains(where: { $0.server != nil })
  }

  private func deleteSelectedPhotos(scope: NativeDeleteTargetScope = .all) async {
    guard !isDeleting else { return }
    let items = selectedItems
    guard !items.isEmpty else { return }
    if scope != .remoteOnly && items.contains(where: { $0.local != nil }) {
      pendingDeleteScope = scope
      showLocalDeleteWarning = true
      return
    }
    await performSelectedDeletion(items: items, scope: scope)
  }

  private func performSelectedDeletion(items: [NativeGridItem], scope: NativeDeleteTargetScope) async {
    guard !isDeleting else { return }
    isDeleting = true
    defer { isDeleting = false }
    do {
      try await nativeDeleteGridItems(items, scope: scope, client: client, device: device)
      if scope == .all || scope == .remoteOnly {
        let serverIDs = Set(items.compactMap { $0.server?.id })
        model.removeAssets(ids: serverIDs)
        var invalidatedLocalIDs = Set<String>()
        for item in items {
          guard let local = item.local,
                let serverID = cloud.matchedServerIDs[local.id], serverIDs.contains(serverID) else { continue }
          invalidatedLocalIDs.insert(local.id)
        }
        cloud.forgetMatches(localIDs: invalidatedLocalIDs)
      }
      selectedIDs.removeAll()
      isSelecting = false
      device.refresh()
      rebuildDayGroups()
    } catch {
      if let partial = error as? NativeDeleteOperationError {
        let deletedIDs = partial.deletedServerIDs
        model.removeAssets(ids: deletedIDs)
        let invalidated = Set(items.compactMap { item -> String? in
          guard let local = item.local, let serverID = cloud.matchedServerIDs[local.id],
                deletedIDs.contains(serverID) else { return nil }
          return local.id
        })
        cloud.forgetMatches(localIDs: invalidated)
      }
      deletionError = "删除未全部成功；已确认的云端删除会更新本地状态，请刷新核对。\(error.localizedDescription)"
      device.refresh()
      await model.refreshLatest()
      rebuildDayGroups()
    }
  }

  private func updateBatchFavorites() async {
    let items = selectedItems
    guard !items.isEmpty else { return }
    let target = !items.allSatisfy(\.isFavorite)
    var succeeded = 0
    var failed = 0
    var partial = 0
    for item in items {
      var successfulCopies = 0
      var failedCopies = 0
      if let server = item.server {
        do { try await client.updateFavorite(id: server.id, isFavorite: target); successfulCopies += 1 }
        catch { failedCopies += 1 }
      }
      if let local = item.local {
        if await device.updateFavorite(ids: [local.id], isFavorite: target) { successfulCopies += 1 }
        else { failedCopies += 1 }
      }
      if failedCopies == 0 && successfulCopies > 0 { succeeded += 1 }
      else if successfulCopies > 0 { partial += 1 }
      else { failed += 1 }
    }
    actionMessage = "收藏\(target ? "已开启" : "已关闭")：全部成功 \(succeeded) 项，部分成功 \(partial) 项，失败 \(failed) 项。"
    device.refresh()
    await model.refreshLatest()
    rebuildDayGroups()
  }

  private func archiveSelected() async {
    let targets = selectedItems
    let missingServerInfo = targets.filter { $0.server == nil && $0.local.flatMap { cloud.matchedServerIDs[$0.id] } != nil }.count
    let candidates = targets.compactMap { item -> (NativeGridItem, String)? in
      guard let server = item.server else { return nil }
      return (item, server.id)
    }
    guard !candidates.isEmpty else { return }
    var succeeded = Set<String>()
    var failures = [String]()
    for (_, id) in candidates {
      do { try await client.updateVisibility(ids: [id], visibility: "archive"); succeeded.insert(id) }
      catch { failures.append(id) }
    }
    archivedServerIDs.formUnion(succeeded)
    model.removeAssets(ids: succeeded)
    selectedIDs.subtract(Set(candidates.filter { succeeded.contains($0.1) }.map { $0.0.id }))
    rebuildDayGroups()
    let localOnlySkipped = targets.filter { $0.server == nil && $0.local != nil }.count
    actionMessage = "归档成功 \(succeeded.count) 项，失败 \(failures.count) 项，跳过本机独有项 \(localOnlySkipped) 项，已匹配但云端信息缺失 \(missingServerInfo) 项。"
  }

  private func prepareSaveToDevice() {
    let targets = selectedItems.filter { $0.server != nil }
    guard !targets.isEmpty else { actionMessage = "没有可保存的云端原件。"; return }
    duplicateSaveCount = targets.filter { $0.local != nil }.count
    showSaveConfirmation = true
  }

  private func saveSelectedToDevice() async {
    if !device.authorized {
      await device.requestAccess()
      guard device.authorized else { actionMessage = "未获得本机照片写入权限。请在系统设置中允许访问后重试。"; return }
    }
    let targets = selectedItems.filter { $0.server != nil }
    var urls: [URL] = []
    var failed = 0
    for item in targets {
      guard let server = item.server else { continue }
      do { urls.append(try await client.originalFile(for: server)) }
      catch { failed += 1 }
    }
    let result = await device.saveFilesToPhotos(urls)
    urls.forEach { try? FileManager.default.removeItem(at: $0) }
    actionMessage = "保存到本机：成功 \(result.saved) 项，失败 \(result.failed + failed) 项。"
  }

  private func addSelectedToServerAlbum(_ albumID: String) async {
    let ids = selectedItems.compactMap { $0.server?.id }
    let skipped = selectedItems.count - ids.count
    guard !ids.isEmpty else { actionMessage = "没有可加入云端相册的资产。"; return }
    do {
      let results = try await client.addAssetsToAlbum(ids: ids, albumID: albumID)
      let summary = nativeBulkOperationSummary(requestedIDs: ids, responses: results)
      actionMessage = "加入云端相册：成功 \(summary.succeeded) 项，失败 \(summary.failed) 项，未确认 \(summary.unconfirmed) 项。\(skipped > 0 ? "跳过本机独有项 \(skipped) 项。" : "")"
    } catch { actionMessage = "加入云端相册失败：\(error.localizedDescription)" }
  }

  private func addSelectedToLocalAlbum(_ albumID: String) async {
    let ids = selectedItems.compactMap { $0.local?.id }
    let skipped = selectedItems.count - ids.count
    guard !ids.isEmpty else { actionMessage = "没有可加入本机相册的资产。"; return }
    if await device.addAssets(ids, toAlbum: albumID) {
      actionMessage = "已加入本机相册 \(ids.count) 项。\(skipped > 0 ? "跳过云端独有项 \(skipped) 项。" : "")"
    } else { actionMessage = "加入本机相册失败；请检查照片权限。" }
  }

  private func triggerBatchShare() {
    guard !isPreparingBatchShare else { return }
    let targets = selectedItems
    guard !targets.isEmpty else { return }
    isPreparingBatchShare = true
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    Task {
      let result = await nativePrepareBatchShare(items: targets, client: client)
      await MainActor.run {
        isPreparingBatchShare = false
        if !result.files.isEmpty {
          batchShareItems = result.files
          if result.failed > 0 { actionMessage = "已准备 \(result.files.count) 项原件；\(result.failed) 项原件暂不可用而跳过。" }
        } else {
          actionMessage = "没有可分享的原件；未以预览替代。"
        }
      }
    }
  }

  private func triggerRefresh(proxy: ScrollViewProxy) {
    guard !isRefreshing else { return }
    isRefreshing = true
    let anchor = visibleAnchorID
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    Task {
      await model.refreshLatest()
      await device.refreshAndWait()
      rebuildDayGroups()
      await cloud.check(device.assets, client: client)
      await loadKnownMatchedServerAssets()
      if let anchor { withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) } }
      isRefreshing = false
    }
  }

  private func positionAtLatestAfterSourceChange(proxy: ScrollViewProxy) {
    pendingSourceChangeScroll = true
    guard hasInitialScrolled else {
      positionInitiallyIfReady(proxy: proxy)
      if hasInitialScrolled { pendingSourceChangeScroll = false }
      return
    }
    let sourceIsLoading: Bool
    switch sourceFilter {
    case .device: sourceIsLoading = device.isLoading
    case .server: sourceIsLoading = model.isLoading
    case .all: sourceIsLoading = model.isLoading || device.isLoading
    }
    guard !sourceIsLoading else { return }
    guard didInitialPosition else {
      let expectedSource = sourceFilter
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        guard pendingSourceChangeScroll, sourceFilter == expectedSource else { return }
        positionAtLatestAfterSourceChange(proxy: proxy)
      }
      return
    }
    let expectedSource = sourceFilter
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      guard pendingSourceChangeScroll, sourceFilter == expectedSource else { return }
      withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
      // A filtered LazyVStack may need another layout pass to resolve its final
      // lazy anchor, especially when switching between very different counts.
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        guard pendingSourceChangeScroll, sourceFilter == expectedSource else { return }
        withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
        pendingSourceChangeScroll = false
      }
    }
  }

  private func positionInitiallyIfReady(proxy: ScrollViewProxy) {
    guard !hasInitialScrolled, initialRemoteLoaded, !model.isLoading, !device.isLoading else { return }
    // Do not commit the initial position while the remote/local timelines are
    // still arriving: a subsequent layout pass would move the bottom anchor.
    scrollToBottom(proxy: proxy, animated: false)
  }

  private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
    if !hasInitialScrolled {
      guard initialRemoteLoaded, !model.isLoading, !device.isLoading else { return }
      hasInitialScrolled = true
      // Lazy grids need a layout pass after the final data update before the
      // bottom anchor has its final position. Keep content hidden until then.
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
          withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
          initialScrollVisible = true
          pendingSourceChangeScroll = false
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            // A final pass catches layout changes caused by revealing the lazy
            // grid after the first two anchor attempts.
            withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
            didInitialPosition = true
          }
        }
      }
    } else {
      DispatchQueue.main.async {
        guard hasInitialScrolled, didInitialPosition else { return }
        if animated {
          withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(bottomAnchor, anchor: .bottom)
          }
        } else {
          withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
        }
      }
    }
  }

  private func requestOlder(proxy: ScrollViewProxy) {
    guard loadingOlderAnchor == nil, model.hasOlder, !model.isLoading, didInitialPosition else { return }
    let anchor = visibleAnchorID ?? cachedDayGroups.first?.assets.first?.id
    loadingOlderAnchor = anchor ?? "pending"
    Task {
      await model.loadOlder()
      if let anchor {
        await Task.yield()
        withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) }
      }
      if model.error != nil { loadingOlderAnchor = nil }
      else {
        try? await Task.sleep(nanoseconds: 300_000_000)
        loadingOlderAnchor = nil
      }
    }
  }

  private func updateSelectionAfterTimelineChange() {
    let visibleIDs = Set(cachedDayGroups.flatMap { $0.assets.map(\.id) })
    selectedIDs.formIntersection(visibleIDs)
    if selectedIDs.isEmpty { isSelecting = false }
  }

  private func refreshExcludedServerAssetIDs() {
    let albumIDs = nativePhotosExcludedAlbumIDs(from: excludedServerAlbumIDsRaw)
    guard !albumIDs.isEmpty else {
      excludedServerAssetIDs = []
      rebuildDayGroups()
      updateSelectionAfterTimelineChange()
      return
    }
    Task {
      var excludedIDs = Set<String>()
      do {
        for albumID in albumIDs {
          try Task.checkCancellation()
          excludedIDs.formUnion(try await client.assetIDs(inServerAlbum: albumID))
        }
      } catch {
        // Keep known exclusions rather than showing albums after a transient API error.
        excludedIDs = excludedServerAssetIDs
      }
      guard albumIDs == nativePhotosExcludedAlbumIDs(from: excludedServerAlbumIDsRaw) else { return }
      await MainActor.run {
        excludedServerAssetIDs = excludedIDs
        rebuildDayGroups()
        updateSelectionAfterTimelineChange()
      }
    }
  }

  private func rebuildDayGroups() {
    var grouped: [Date: [NativeGridItem]] = [:]
    var calendar = Calendar.autoupdatingCurrent
    calendar.timeZone = .autoupdatingCurrent
    for item in filteredTimelineAssets {
      let date = calendar.startOfDay(for: item.date)
      grouped[date, default: []].append(item)
    }
    let groups = grouped.keys.sorted().map { date in
      NativeDayGroup(date: date, assets: grouped[date] ?? [])
    }
    cachedDayGroups = groups

    var seenYearMonths = Set<Int>()
    var firstDates = Set<Date>()
    for group in groups {
      let year = calendar.component(.year, from: group.date)
      let month = calendar.component(.month, from: group.date)
      if seenYearMonths.insert(year * 100 + month).inserted {
        firstDates.insert(group.date)
      }
    }
    cachedFirstGroupDatesInMonth = firstDates
  }

  private var allOrderedAssetIDs: [String] {
    cachedDayGroups.flatMap { $0.assets.map(\.id) }
  }

  private func enterSelection(startingWith id: String, at location: CGPoint? = nil) {
    guard !isSelecting else { return }
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    isSelecting = true
    dragStartAssetID = id
    let startLoc = location ?? itemBounds[id].map { CGPoint(x: $0.midX, y: $0.midY) }
    dragStartLocation = startLoc
    dragInitialSelectedIDs = selectedIDs
    let alreadySelected = selectedIDs.contains(id)
    dragSelectMode = !alreadySelected
    if dragSelectMode {
      selectedIDs.insert(id)
    } else {
      selectedIDs.remove(id)
    }
  }

  private func startDragSelectionInSelectMode(startingWith id: String, at location: CGPoint? = nil) {
    guard dragStartAssetID != id || dragStartLocation == nil else { return }
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    dragStartAssetID = id
    let startLoc = location ?? itemBounds[id].map { CGPoint(x: $0.midX, y: $0.midY) }
    dragStartLocation = startLoc
    dragInitialSelectedIDs = selectedIDs
    let alreadySelected = selectedIDs.contains(id)
    dragSelectMode = !alreadySelected
    if dragSelectMode {
      selectedIDs.insert(id)
    } else {
      selectedIDs.remove(id)
    }
  }

  private func handle2DDragSelection(at location: CGPoint) {
    guard isSelecting else { return }
    if dragStartLocation == nil {
      dragStartLocation = location
      dragInitialSelectedIDs = selectedIDs
      if let hitID = itemBounds.first(where: { $0.value.contains(location) })?.key {
        dragStartAssetID = hitID
        dragSelectMode = !selectedIDs.contains(hitID)
      } else {
        dragSelectMode = true
      }
    }
    
    let startLoc = dragStartLocation ?? location
    let minX = min(startLoc.x, location.x)
    let minY = min(startLoc.y, location.y)
    let maxX = max(startLoc.x, location.x)
    let maxY = max(startLoc.y, location.y)
    
    let selectionRect = CGRect(
      x: minX,
      y: minY,
      width: max(maxX - minX, 6),
      height: max(maxY - minY, 6)
    )
    
    var itemsInRect = Set<String>()
    for (id, frame) in itemBounds {
      if frame.intersects(selectionRect) {
        itemsInRect.insert(id)
      }
    }
    if let startID = dragStartAssetID {
      itemsInRect.insert(startID)
    }
    
    var updated = dragInitialSelectedIDs
    if dragSelectMode {
      updated.formUnion(itemsInRect)
    } else {
      updated.subtract(itemsInRect)
    }
    
    if updated != selectedIDs {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      selectedIDs = updated
    }
  }

  private func finishDragSelection() {
    dragStartLocation = nil
    dragStartAssetID = nil
    dragInitialSelectedIDs.removeAll()
  }

  private func toggleSelection(_ id: String) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    if selectedIDs.contains(id) { selectedIDs.remove(id) } else { selectedIDs.insert(id) }
  }

  private func clearSelection() {
    isSelecting = false
    isDragSelecting = false
    selectedIDs.removeAll()
    finishDragSelection()
  }

  private func cloudSymbol(for entry: NativeGridItem) -> String {
    guard let local = entry.local else { return "cloud" }
    if entry.server != nil || cloud.matchedServerIDs[local.id] != nil { return "checkmark.icloud" }
    if cloud.failedVerificationIDs.contains(local.id) { return "exclamationmark.icloud" }
    return cloud.checkedIDs.contains(local.id) ? "icloud.slash" : "questionmark.icloud"
  }

  private func cloudDescription(for entry: NativeGridItem) -> String {
    let typeName = entry.isVideo ? "视频" : "照片"
    if let local = entry.local {
      if entry.server != nil || cloud.matchedServerIDs[local.id] != nil { return "已核验云端副本的\(typeName)" }
      if cloud.failedVerificationIDs.contains(local.id) { return "核验失败、云端状态未知的本机\(typeName)" }
      return cloud.checkedIDs.contains(local.id) ? "仅本机\(typeName)" : "云端状态未知的本机\(typeName)"
    }
    return "仅云端\(typeName)"
  }
}

private struct NativeDayGroup {
  let date: Date
  let assets: [NativeGridItem]
}

private struct NativePhotosLocalAlbumPicker: View {
  let albums: [NativeDeviceAlbum]
  let onSelect: (String) -> Void
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      List(albums) { album in
        Button {
          dismiss()
          onSelect(album.id)
        } label: {
          HStack {
            Text(album.name)
            Spacer()
            Text("\(album.count)").foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("选择本机相册")
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("取消") { dismiss() } } }
    }
  }
}

private struct NativePhotosServerAlbumPicker: View {
  let client: NativeImmichClient
  let onSelect: (String) -> Void
  @Environment(\.dismiss) private var dismiss
  @State private var albums: [NativeServerAlbum] = []
  @State private var loading = true
  @State private var error: String?

  var body: some View {
    NavigationView {
      Group {
        if loading { ProgressView("正在加载云端相册…") }
        else if let error { VStack { Text(error); Button("重试") { Task { await load() } } } }
        else {
          List(albums) { album in
            Button {
              dismiss()
              onSelect(album.id)
            } label: {
              HStack {
                Text(album.name)
                Spacer()
                Text("\(album.count)").foregroundColor(.secondary)
              }
            }
          }
        }
      }
      .navigationTitle("选择云端相册")
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("取消") { dismiss() } } }
      .task { await load() }
    }
  }

  @MainActor private func load() async {
    loading = true
    error = nil
    do { albums = try await client.serverAlbums() }
    catch { self.error = error.localizedDescription }
    loading = false
  }
}

struct NativeItemFramePreferenceKey: PreferenceKey {
  static var defaultValue: [String: CGRect] = [:]
  static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}

enum NativeThumbnailCache {
  static let images: NSCache<NSString, UIImage> = {
    let cache = NSCache<NSString, UIImage>()
    cache.countLimit = 1500
    cache.totalCostLimit = 200 * 1024 * 1024
    return cache
  }()

  static func downsampledImage(from data: Data, maxPixelSize: Int) -> UIImage? {
    let options: [CFString: Any] = [
      kCGImageSourceShouldCache: false
    ]
    guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
      return UIImage(data: data)
    }
    let thumbOptions: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
    ]
    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbOptions as CFDictionary) else {
      return UIImage(data: data)
    }
    return UIImage(cgImage: cgImage)
  }
}

@MainActor
private final class NativeThumbnailRequestLimiter {
  static let shared = NativeThumbnailRequestLimiter()
  private let maximumActive = 12
  private var active = 0
  private var waiters: [CheckedContinuation<Void, Never>] = []

  func acquire() async {
    if active < maximumActive {
      active += 1
    } else {
      await withCheckedContinuation { waiters.append($0) }
    }
  }

  func release() {
    if waiters.isEmpty {
      active = max(0, active - 1)
    } else {
      waiters.removeFirst().resume()
    }
  }
}

struct NativeThumbhashBackground: View {
  let thumbhash: String?

  var body: some View {
    if let gradientColors, !gradientColors.isEmpty {
      LinearGradient(
        colors: gradientColors,
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    } else {
      Rectangle().fill(Color(uiColor: .secondarySystemBackground))
    }
  }

  private var gradientColors: [Color]? {
    guard let hash = thumbhash, !hash.isEmpty,
          let data = Data(base64Encoded: hash), data.count >= 5 else {
      return nil
    }
    func dc(_ byte: UInt8) -> Double {
      let v = Double((byte & 0x3F) * 2)
      return min(1.0, max(0.0, (v * 255.0 / 126.0) / 255.0))
    }
    let r = dc(data[1])
    let g = dc(data[2])
    let b = dc(data[3])
    let c1 = Color(red: r, green: g, blue: b)
    let c2 = Color(red: max(0.0, r * 0.55), green: max(0.0, g * 0.55), blue: max(0.0, b * 0.55))
    return [c1, c2]
  }
}

struct NativeThumbnail: View {
  let client: NativeImmichClient
  let asset: NativeAsset
  var columns: Int = 3
  @State private var image: UIImage?

  var body: some View {
    Group {
      if let image {
        Image(uiImage: image)
          .resizable()
          .scaledToFill()
      } else {
        NativeThumbhashBackground(thumbhash: asset.thumbhash)
      }
    }
    .task(id: "\(client.config.serverUrl):\(asset.id):\(isLowDensity ? "p" : "t")") {
      image = nil
      let credential = client.config.accessToken ?? client.config.apiKey ?? ""
      let accountDigest = SHA256.hash(data: Data("\(client.config.serverUrl):\(credential)".utf8))
        .map { String(format: "%02x", $0) }.joined()
      let sizeTag = isLowDensity ? "preview" : "thumbnail"
      let cacheKey = "\(accountDigest):\(asset.id):\(sizeTag)"
      let key = NSString(string: cacheKey)
      if let cached = NativeThumbnailCache.images.object(forKey: key) {
        image = cached
        return
      }
      let maxDim = maxPixelDimension
      if let cachedData = await NativeThumbnailDiskCache.shared.data(for: cacheKey) {
        let decoded = await Task.detached(priority: .userInitiated) {
          NativeThumbnailCache.downsampledImage(from: cachedData, maxPixelSize: maxDim)
        }.value
        if let decoded {
          NativeThumbnailCache.images.setObject(
            decoded,
            forKey: key,
            cost: Int(decoded.size.width * decoded.size.height * 4)
          )
          image = decoded
          return
        }
      }

      // If columns > 3, request lightweight 250px thumbnail directly (10x faster)
      // Only request high-res preview when zooming into 1~3 large columns
      let preferredURL = isLowDensity ? client.thumbnailURL(for: asset, size: "preview") : client.thumbnailURL(for: asset, size: "thumbnail")
      let fallbackURL = isLowDensity ? client.thumbnailURL(for: asset, size: "thumbnail") : client.thumbnailURL(for: asset, size: "preview")
      guard let url = preferredURL ?? fallbackURL else { return }

      await NativeThumbnailRequestLimiter.shared.acquire()
      defer { NativeThumbnailRequestLimiter.shared.release() }
      guard !Task.isCancelled else { return }
      do {
        let data = try await client.thumbnailData(for: url)
        guard !Task.isCancelled else { return }
        let decoded = await Task.detached(priority: .userInitiated) {
          NativeThumbnailCache.downsampledImage(from: data, maxPixelSize: maxDim)
        }.value
        guard !Task.isCancelled, let decoded else { return }
        await NativeThumbnailDiskCache.shared.store(data, for: cacheKey)
        NativeThumbnailCache.images.setObject(
          decoded,
          forKey: key,
          cost: Int(decoded.size.width * decoded.size.height * 4)
        )
        image = decoded
      } catch {
        if let fallbackURL, fallbackURL != url {
          do {
            let data = try await client.thumbnailData(for: fallbackURL)
            guard !Task.isCancelled else { return }
            let decoded = await Task.detached(priority: .userInitiated) {
              NativeThumbnailCache.downsampledImage(from: data, maxPixelSize: maxDim)
            }.value
            guard !Task.isCancelled, let decoded else { return }
            await NativeThumbnailDiskCache.shared.store(data, for: cacheKey)
            NativeThumbnailCache.images.setObject(
              decoded,
              forKey: key,
              cost: Int(decoded.size.width * decoded.size.height * 4)
            )
            image = decoded
          } catch { image = nil }
        } else {
          image = nil
        }
      }
    }
  }

  private var isLowDensity: Bool {
    columns <= 3
  }

  private var maxPixelDimension: Int {
    if columns <= 2 {
      return 600
    } else if columns <= 4 {
      return 360
    } else if columns <= 7 {
      return 220
    } else {
      return 130
    }
  }
}

// MARK: - Native Unified Gallery Viewer (Full-featured Asset Viewer)

import AVKit

struct NativeUnifiedGalleryViewer: View {
  let client: NativeImmichClient
  let device: NativeDeviceLibrary
  @State private var items: [NativeGridItem]
  let initialItem: NativeGridItem
  var onDeleteItem: ((NativeGridItem, NativeDeleteTargetScope) -> Void)? = nil
  var onServerAssetUpdated: ((NativeAsset) -> Void)? = nil
  var onServerAssetArchived: ((String) -> Void)? = nil

  @Environment(\.dismiss) private var dismiss
  @State private var currentIndex: Int = 0
  @State private var showChrome = true
  @State private var isCurrentImageZoomed = false
  @State private var showInfoSheet = false
  @State private var isFavorite = false
  @State private var isProcessingFavorite = false
  @State private var showMoreActions = false
  @State private var isPreparingShare = false
  @State private var shareTask: Task<Void, Never>?
  @State private var viewerMessage: String?
  @State private var dragOffset: CGSize = .zero
  @State private var shareItem: Any? = nil
  @State private var showDeleteScopeDialog = false
  @State private var showViewerLocalDeleteWarning = false
  @State private var pendingViewerDeleteScope: NativeDeleteTargetScope = .all
  @State private var isDeletingItem = false
  @State private var deleteErrorMessage: String? = nil

  init(
    client: NativeImmichClient,
    device: NativeDeviceLibrary,
    items: [NativeGridItem],
    initialItem: NativeGridItem,
    onDeleteItem: ((NativeGridItem, NativeDeleteTargetScope) -> Void)? = nil,
    onServerAssetUpdated: ((NativeAsset) -> Void)? = nil,
    onServerAssetArchived: ((String) -> Void)? = nil
  ) {
    self.client = client
    self.device = device
    _items = State(initialValue: items)
    self.initialItem = initialItem
    self.onDeleteItem = onDeleteItem
    self.onServerAssetUpdated = onServerAssetUpdated
    self.onServerAssetArchived = onServerAssetArchived
    let index = items.firstIndex(where: { $0.id == initialItem.id }) ?? 0
    _currentIndex = State(initialValue: index)
    _isFavorite = State(initialValue: initialItem.isFavorite)
  }

  private var currentItem: NativeGridItem? {
    guard items.indices.contains(currentIndex) else { return nil }
    return items[currentIndex]
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      if items.isEmpty {
        Text("当前照片已删除").foregroundColor(.white)
      } else {
        TabView(selection: $currentIndex) {
          ForEach(items.indices, id: \.self) { idx in
            NativeSingleAssetPage(
              client: client,
              device: device,
              item: items[idx],
              onZoomChanged: { zoomed in
                if idx == currentIndex { isCurrentImageZoomed = zoomed }
              },
              onTap: {
                withAnimation(.easeInOut(duration: 0.2)) {
                  showChrome.toggle()
                }
              }
            )
            .id(items[idx].id)
            .tag(idx)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .offset(y: max(0, dragOffset.height))
        .scaleEffect(dragOffset.height > 0 ? max(0.8, 1.0 - (dragOffset.height / 1000.0)) : 1.0)
        .opacity(dragOffset.height > 0 ? max(0.4, 1.0 - Double(dragOffset.height / 500.0)) : 1.0)
        .simultaneousGesture(
          DragGesture()
            .onChanged { value in
              guard !isCurrentImageZoomed else { return }
              // Close by swiping down only when the image is at its base zoom.
              if value.translation.height > 10 && abs(value.translation.height) > abs(value.translation.width) {
                dragOffset = value.translation
              }
            }
            .onEnded { value in
              guard !isCurrentImageZoomed else { dragOffset = .zero; return }
              if dragOffset.height > 120 {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()
              } else {
                withAnimation(.interactiveSpring()) {
                  dragOffset = .zero
                }
              }
            }
        )
      }

      // Top & Bottom Overlay Chrome
      if showChrome {
        VStack {
          // Top Bar
          HStack {
            Button {
              dismiss()
            } label: {
              Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
            }

            Spacer()

            if let item = currentItem {
              VStack(spacing: 2) {
                if item.local?.isLivePhoto == true || item.server?.livePhotoVideoId != nil {
                  Label("实况 · 长按播放", systemImage: "livephoto")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                }
                Text(NativeImmichClient.formatChineseDate(item.date))
                  .font(.subheadline.weight(.semibold))
                  .foregroundColor(.white)
                Text("\(currentIndex + 1) / \(items.count)")
                  .font(.caption2)
                  .foregroundColor(.white.opacity(0.75))
              }
            }

            Spacer()

            Button {
              showInfoSheet = true
            } label: {
              Image(systemName: "info.circle")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 48)

          Spacer()

          // Bottom Bar
          HStack(spacing: 24) {
            // Share
            Button {
              triggerShare()
            } label: {
              VStack(spacing: 4) {
                if isPreparingShare { ProgressView().tint(.white) }
                else { Image(systemName: "square.and.arrow.up").font(.system(size: 19)) }
                Text("分享").font(.caption2)
              }
              .foregroundColor(.white)
            }
            .disabled(isPreparingShare)
            if isPreparingShare {
              Button("取消准备") {
                shareTask?.cancel()
                shareTask = nil
                isPreparingShare = false
              }
              .font(.caption2)
              .foregroundColor(.white)
            }

            // Favorite
            Button {
              toggleFavorite()
            } label: {
              VStack(spacing: 4) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                  .font(.system(size: 19))
                  .foregroundColor(isFavorite ? .red : .white)
                Text(isFavorite ? "已收藏" : "收藏").font(.caption2)
                  .foregroundColor(.white)
              }
            }
            .disabled(isProcessingFavorite || currentItem == nil)
            .opacity(currentItem != nil ? 1 : 0.4)

            // Info Details
            Button {
              showInfoSheet = true
            } label: {
              VStack(spacing: 4) {
                Image(systemName: "info.circle")
                  .font(.system(size: 19))
                Text("详情").font(.caption2)
              }
              .foregroundColor(.white)
            }

            Button {
              showMoreActions = true
            } label: {
              VStack(spacing: 4) {
                Image(systemName: "ellipsis.circle").font(.system(size: 19))
                Text("更多").font(.caption2)
              }
              .foregroundColor(.white)
            }
            .disabled(isDeletingItem || currentItem == nil)
          }
          .padding(.vertical, 10)
          .padding(.horizontal, 18)
          .background(Color.black.opacity(0.65))
          .cornerRadius(24)
          .padding(.bottom, 24)
        }
        .transition(.opacity)
      }
    }
    .confirmationDialog("删除范围", isPresented: $showDeleteScopeDialog, titleVisibility: .visible) {
      if currentItem?.local != nil {
        Button("仅删除本地", role: .destructive) {
          pendingViewerDeleteScope = .localOnly
          showViewerLocalDeleteWarning = true
        }
      }
      if currentItem?.server != nil {
        Button("仅删除云端", role: .destructive) { performDeleteItem(scope: .remoteOnly) }
      }
      if currentItem?.local != nil && currentItem?.server != nil {
        Button("全部删除", role: .destructive) {
          pendingViewerDeleteScope = .all
          showViewerLocalDeleteWarning = true
        }
      }
      Button("取消", role: .cancel) {}
    } message: {
      Text("选择要删除的副本；只删除云端时，若本机仍有原件且开启自动备份，照片可能再次上传。")
    }
    .alert("删除失败", isPresented: Binding(get: { deleteErrorMessage != nil }, set: { if !$0 { deleteErrorMessage = nil } })) {
      Button("确定", role: .cancel) { deleteErrorMessage = nil }
    } message: {
      Text(deleteErrorMessage ?? "未知错误")
    }
    .onChange(of: currentIndex) { newIdx in
      isCurrentImageZoomed = false
      if items.indices.contains(newIdx) { isFavorite = items[newIdx].isFavorite }
    }
    .onDisappear {
      shareTask?.cancel()
      shareTask = nil
      if let url = shareItem as? URL { try? FileManager.default.removeItem(at: url) }
      shareItem = nil
    }
    .alert("操作结果", isPresented: Binding(get: { viewerMessage != nil }, set: { if !$0 { viewerMessage = nil } })) {
      Button("好", role: .cancel) { viewerMessage = nil }
    } message: { Text(viewerMessage ?? "") }
    .alert("确认删除本机照片", isPresented: $showViewerLocalDeleteWarning) {
      Button("取消", role: .cancel) {}
      Button("继续删除", role: .destructive) { performDeleteItem(scope: pendingViewerDeleteScope) }
    } message: { Text("此操作会从系统照片中永久删除；若开启 iCloud Photos，删除可能传播至其他设备。") }
    .confirmationDialog("更多操作", isPresented: $showMoreActions, titleVisibility: .visible) {
      Button("删除…", role: .destructive) { showDeleteScopeDialog = true }
      if currentItem?.server != nil { Button("归档云端副本") { Task { await archiveCurrentServerCopy() } } }
    } message: { Text("操作只影响具有对应副本的来源。") }
    .sheet(isPresented: $showInfoSheet) {
      if let item = currentItem {
        NativeAssetInfoSheet(client: client, device: device, item: item)
      }
    }
    .sheet(item: Binding<NativeSharePayload?>(
      get: { shareItem.map { NativeSharePayload(content: $0) } },
      set: { if $0 == nil { shareItem = nil } }
    )) { payload in
      NativeActivityView(activityItems: payload.content)
    }
    .statusBarHidden(true)
  }

  private func performDeleteItem(scope: NativeDeleteTargetScope) {
    guard let item = currentItem, !isDeletingItem else { return }
    isDeletingItem = true
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    Task {
      do {
        try await nativeDeleteGridItems([item], scope: scope, client: client, device: device)
        await MainActor.run {
          isDeletingItem = false
          onDeleteItem?(item, scope)
          retainViewerAfterDeleting(item, scope: scope)
        }
      } catch {
        await MainActor.run {
          isDeletingItem = false
          if let partial = error as? NativeDeleteOperationError,
             let serverID = item.server?.id, partial.deletedServerIDs.contains(serverID) {
            onDeleteItem?(item, .remoteOnly)
            retainViewerAfterDeleting(item, scope: .remoteOnly)
          }
          deleteErrorMessage = "删除失败：\(error.localizedDescription)"
        }
      }
    }
  }

  private func retainViewerAfterDeleting(_ deletedItem: NativeGridItem, scope: NativeDeleteTargetScope) {
    guard items.indices.contains(currentIndex) else { return }
    switch scope {
    case .all:
      removeCurrentViewerItem()
    case .localOnly:
      if let server = deletedItem.server {
        items[currentIndex] = NativeGridItem(server: server, local: nil)
      } else {
        removeCurrentViewerItem()
      }
    case .remoteOnly:
      if let local = deletedItem.local {
        items[currentIndex] = NativeGridItem(server: nil, local: local)
      } else {
        removeCurrentViewerItem()
      }
    }
    if items.indices.contains(currentIndex) { isFavorite = items[currentIndex].isFavorite }
    dragOffset = .zero
    showChrome = true
  }

  private func removeCurrentViewerItem() {
    guard items.indices.contains(currentIndex) else { return }
    items.remove(at: currentIndex)
    if items.isEmpty {
      currentIndex = 0
    } else {
      currentIndex = min(currentIndex, items.count - 1)
      isFavorite = items[currentIndex].isFavorite
    }
  }

  private func archiveCurrentServerCopy() async {
    guard let item = currentItem, let server = item.server else { return }
    do {
      try await client.updateVisibility(ids: [server.id], visibility: "archive")
      onServerAssetArchived?(server.id)
      if let local = item.local {
        items[currentIndex] = NativeGridItem(server: nil, local: local)
        isFavorite = local.isFavorite
      } else {
        removeCurrentViewerItem()
      }
      viewerMessage = "已归档云端副本；本机副本保留。"
    } catch { viewerMessage = "归档失败：\(error.localizedDescription)" }
  }

  private func toggleFavorite() {
    guard let item = currentItem, !isProcessingFavorite else { return }
    let newFav = !isFavorite
    isProcessingFavorite = true
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    Task {
      var succeeded = 0
      var failed = 0
      var serverSucceeded = false
      var localSucceeded = false
      if let server = item.server {
        do { try await client.updateFavorite(id: server.id, isFavorite: newFav); succeeded += 1; serverSucceeded = true }
        catch { failed += 1 }
      }
      if let local = item.local {
        if await device.updateFavorite(ids: [local.id], isFavorite: newFav) { succeeded += 1; localSucceeded = true }
        else { failed += 1 }
      }
      // A paired asset can succeed on just one side. Never synthesize a
      // successful server favorite when its request actually failed.
      let serverUpdated = serverSucceeded && item.server != nil
      let localUpdated = localSucceeded && item.local != nil
      let updatedServer: NativeAsset? = item.server.map { server in
        guard serverUpdated else { return server }
        return NativeAsset(
          id: server.id, date: server.date, isImage: server.isImage, isFavorite: newFav,
          thumbhash: server.thumbhash, livePhotoVideoId: server.livePhotoVideoId,
          originalFileName: server.originalFileName, originalMimeType: server.originalMimeType,
          width: server.width, height: server.height, fileSizeInByte: server.fileSizeInByte,
          latitude: server.latitude, longitude: server.longitude, isArchived: server.isArchived
        )
      }
      let updatedLocal: NativeDeviceAsset? = item.local.map { local in
        guard localUpdated else { return local }
        return NativeDeviceAsset(
          id: local.id, date: local.date, isVideo: local.isVideo,
          isLivePhoto: local.isLivePhoto, contentVersion: local.contentVersion,
          isFavorite: newFav
        )
      }
      if serverUpdated, let updatedServer { onServerAssetUpdated?(updatedServer) }
      if let index = items.firstIndex(where: { $0.id == item.id }) {
        items[index] = NativeGridItem(server: updatedServer, local: updatedLocal)
        if index == currentIndex {
          isFavorite = updatedServer?.isFavorite == true || updatedLocal?.isFavorite == true
        }
      }
      isProcessingFavorite = false
      viewerMessage = "收藏更新：云端\(item.server == nil ? "无副本" : (serverSucceeded ? "成功" : "失败"))；本机\(item.local == nil ? "无副本" : (localSucceeded ? "成功" : "失败"))。成功 \(succeeded) 份，失败 \(failed) 份。"
    }
  }

  private func triggerShare() {
    guard let item = currentItem, !isPreparingShare else { return }
    isPreparingShare = true
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    shareTask = Task {
      var preparedURL: URL?
      defer {
        if Task.isCancelled, let preparedURL { try? FileManager.default.removeItem(at: preparedURL) }
        isPreparingShare = false
        shareTask = nil
      }
      do {
        let shared: Any
        if let local = item.local {
          guard let source = PHAsset.fetchAssets(withLocalIdentifiers: [local.id], options: nil).firstObject else {
            throw NativeShareError.originalUnavailable
          }
          let result = try await nativeOriginalFile(for: source)
          preparedURL = result
          shared = result
        } else if let server = item.server {
          let result = try await client.originalFile(for: server)
          preparedURL = result
          shared = result
        } else {
          throw NativeShareError.originalUnavailable
        }
        guard !Task.isCancelled else { return }
        shareItem = shared
      } catch {
        guard !Task.isCancelled else { return }
        viewerMessage = "原件暂不可分享。请检查网络、照片权限或 iCloud 原件状态后重试。\n\(error.localizedDescription)"
      }
    }
  }
}

private enum NativeShareError: LocalizedError {
  case originalUnavailable
  var errorDescription: String? { "无法读取原件。" }
}

@MainActor
private func nativeOriginalFile(for asset: PHAsset) async throws -> URL {
  guard let resource = asset.getResource() else { throw NativeShareError.originalUnavailable }
  let ext = URL(fileURLWithPath: resource.originalFilename).pathExtension
  let fileName = ext.isEmpty ? UUID().uuidString : "\(UUID().uuidString).\(ext)"
  let target = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
  let options = PHAssetResourceRequestOptions()
  options.isNetworkAccessAllowed = true
  do {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      PHAssetResourceManager.default().writeData(for: resource, toFile: target, options: options) { error in
        if let error { continuation.resume(throwing: error) }
        else { continuation.resume(returning: ()) }
      }
    }
  } catch {
    try? FileManager.default.removeItem(at: target)
    throw error
  }
  return target
}

struct NativeSharePayload: Identifiable {
  let id = UUID()
  let content: [Any]

  init(content: Any) {
    if let array = content as? [Any] {
      self.content = array
    } else {
      self.content = [content]
    }
  }

  init(contents: [Any]) {
    self.content = contents
  }
}

struct NativeActivityView: UIViewControllerRepresentable {
  let activityItems: [Any]

  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    let temporaryURLs = activityItems.compactMap { $0 as? URL }.filter { $0.path.hasPrefix(FileManager.default.temporaryDirectory.path) }
    controller.completionWithItemsHandler = { _, _, _, _ in
      temporaryURLs.forEach { try? FileManager.default.removeItem(at: $0) }
    }
    return controller
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct NativeBatchShareResult {
  let files: [Any]
  let failed: Int
}

@MainActor
func nativePrepareBatchShare(items: [NativeGridItem], client: NativeImmichClient) async -> NativeBatchShareResult {
  var results: [Any] = []
  var failed = 0
  for item in items {
    do {
      if let local = item.local,
         let asset = PHAsset.fetchAssets(withLocalIdentifiers: [local.id], options: nil).firstObject {
        results.append(try await nativeOriginalFile(for: asset))
      } else if let server = item.server {
        results.append(try await client.originalFile(for: server))
      } else {
        failed += 1
      }
    } catch {
      failed += 1
    }
  }
  return NativeBatchShareResult(files: results, failed: failed)
}

private struct NativeSingleAssetPage: View {
  let client: NativeImmichClient
  let device: NativeDeviceLibrary
  let item: NativeGridItem
  let onZoomChanged: (Bool) -> Void
  let onTap: () -> Void

  @State private var image: UIImage?
  @State private var isLoading = true
  @State private var loadError: String?
  @State private var player: AVPlayer?
  @State private var livePhoto: PHLivePhoto?
  @State private var livePlayer: AVPlayer?
  @State private var isLivePlaying = false

  private var isLive: Bool {
    item.local?.isLivePhoto == true || item.server?.livePhotoVideoId != nil
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.black.ignoresSafeArea()

        if item.isVideo {
          if let player {
            VideoPlayer(player: player)
              .frame(width: proxy.size.width, height: proxy.size.height)
              .ignoresSafeArea()
              .onAppear { player.play() }
              .onDisappear { player.pause() }
          } else {
            VStack(spacing: 12) {
              if isLoading { ProgressView().tint(.white) }
              else {
                Text(loadError ?? "视频暂不可用").font(.caption).foregroundColor(.white.opacity(0.8)).multilineTextAlignment(.center)
                Button("重试") { Task { await loadAssetContent() } }.buttonStyle(.bordered).tint(.white)
              }
            }
          }
        } else {
          if isLivePlaying, let livePlayer, livePhoto == nil {
            VideoPlayer(player: livePlayer)
              .frame(width: proxy.size.width, height: proxy.size.height)
              .allowsHitTesting(false)
          } else if let livePhoto {
            NativeLivePhotoView(livePhoto: livePhoto, isPlaying: isLivePlaying)
              .frame(width: proxy.size.width, height: proxy.size.height)
          } else if let image {
            NativeZoomableImageView(image: image, size: proxy.size, onTap: onTap, onZoomChanged: onZoomChanged)
          } else {
            VStack(spacing: 10) {
              if isLoading { ProgressView().tint(.white) }
              else {
                Image(systemName: "photo").font(.system(size: 42)).foregroundColor(.white.opacity(0.5))
                Text(loadError ?? "无法加载原件").font(.caption).foregroundColor(.white.opacity(0.8)).multilineTextAlignment(.center)
                Button("重试") { Task { await loadAssetContent() } }.buttonStyle(.bordered).tint(.white)
              }
            }
            .padding()
          }
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        onTap()
      }
      .onLongPressGesture(minimumDuration: 0.35, maximumDistance: 15, pressing: { pressing in
        if !pressing { stopLivePlayback() }
      }, perform: {
        startLivePlayback()
      })
    }
    .task {
      await loadAssetContent()
    }
    .onDisappear {
      player?.pause()
      player = nil
      stopLivePlayback()
      livePlayer = nil
    }
  }

  private func startLivePlayback() {
    guard isLive, !item.isVideo, livePhoto != nil || livePlayer != nil else { return }
    isLivePlaying = true
    livePlayer?.seek(to: .zero)
    livePlayer?.play()
  }

  private func stopLivePlayback() {
    isLivePlaying = false
    livePlayer?.pause()
  }

  private func loadAssetContent() async {
    isLoading = true
    loadError = nil
    defer { isLoading = false }

    if item.isVideo {
      if let local = item.local {
        guard let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [local.id], options: nil).firstObject else {
          loadError = "照片权限不足或本机视频已不存在。"
          return
        }
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
          PHImageManager.default().requestPlayerItem(forVideo: phAsset, options: options) { playerItem, info in
            Task { @MainActor in
              if let playerItem {
                let avPlayer = AVPlayer(playerItem: playerItem)
                avPlayer.actionAtItemEnd = .pause
                player = avPlayer
              } else {
                loadError = Self.photoKitErrorMessage(info)
              }
              continuation.resume()
            }
          }
        }
      } else if let server = item.server {
        let base = client.config.apiEndpoint ?? (NativeImmichClient.normalize(client.config.serverUrl) + "/api")
        if let videoURL = URL(string: base + "/assets/\(server.id)/video/playback") {
          var req = URLRequest(url: videoURL)
          if let token = client.config.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          }
          if let key = client.config.apiKey {
            req.setValue(key, forHTTPHeaderField: "x-api-key")
          }
          let asset = AVURLAsset(url: videoURL, options: ["AVURLAssetHTTPHeaderFieldsKey": req.allHTTPHeaderFields ?? [:]])
          let item = AVPlayerItem(asset: asset)
          let avPlayer = AVPlayer(playerItem: item)
          avPlayer.actionAtItemEnd = .pause
          player = avPlayer
        } else { loadError = "服务器视频播放地址无效" }
      } else { loadError = "视频资产来源不可用" }
      if player == nil { loadError = "视频暂不可用；请检查网络或访问权限后重试。" }
      return
    }

    // Load Image
    if let local = item.local {
      guard let source = PHAsset.fetchAssets(withLocalIdentifiers: [local.id], options: nil).firstObject else {
        loadError = "照片权限不足或本机原件已不存在。"
        return
      }
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = true
      options.deliveryMode = .highQualityFormat
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        PHImageManager.default().requestImage(for: source, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { result, info in
          guard info?[PHImageResultIsDegradedKey] as? Bool != true else { return }
          Task { @MainActor in
            if let result { image = result }
            else { loadError = Self.photoKitErrorMessage(info) }
            continuation.resume()
          }
        }
      }
      if local.isLivePhoto {
        let liveOptions = PHLivePhotoRequestOptions()
        liveOptions.isNetworkAccessAllowed = true
        PHImageManager.default().requestLivePhoto(for: source, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: liveOptions) { result, info in
          guard info?[PHImageResultIsDegradedKey] as? Bool != true else { return }
          DispatchQueue.main.async { livePhoto = result }
        }
      }
    } else if let server = item.server {
      if let videoID = server.livePhotoVideoId {
        let base = client.config.apiEndpoint ?? (NativeImmichClient.normalize(client.config.serverUrl) + "/api")
        if let url = URL(string: base + "/assets/\(videoID)/video/playback") {
          var request = URLRequest(url: url)
          if let token = client.config.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          }
          if let key = client.config.apiKey {
            request.setValue(key, forHTTPHeaderField: "x-api-key")
          }
          let videoAsset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": request.allHTTPHeaderFields ?? [:]])
          livePlayer = AVPlayer(playerItem: AVPlayerItem(asset: videoAsset))
        }
      }
      if let url = client.originalURL(for: server) {
        do {
          let data = try await client.imageData(for: url)
          if let decoded = UIImage(data: data) { image = decoded }
          else { loadError = "服务器返回的原件格式无法显示" }
        } catch {
          loadError = Self.networkErrorMessage(error)
        }
      } else { loadError = "云端原件地址无效" }
    }
  }

  private static func photoKitErrorMessage(_ info: [AnyHashable: Any]?) -> String {
    if info?[PHImageCancelledKey] as? Bool == true { return "加载已取消" }
    if info?[PHImageResultIsInCloudKey] as? Bool == true { return "iCloud 原件尚未下载；请检查网络后重试" }
    if let error = info?[PHImageErrorKey] as? Error { return "照片权限或原件读取失败：\(error.localizedDescription)" }
    return "本机原件暂不可用；检查照片权限或 iCloud 状态后重试"
  }

  private static func networkErrorMessage(_ error: Error) -> String {
    if let urlError = error as? URLError, urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
      return "当前离线；云端原件无法加载"
    }
    return "云端原件加载失败：\(error.localizedDescription)"
  }
}

// PhotoKit owns the local Live Photo playback (including its paired motion/audio).
private struct NativeLivePhotoView: UIViewRepresentable {
  let livePhoto: PHLivePhoto
  let isPlaying: Bool

  func makeUIView(context: Context) -> PHLivePhotoView {
    let view = PHLivePhotoView()
    view.contentMode = .scaleAspectFit
    view.isMuted = false
    return view
  }

  func updateUIView(_ view: PHLivePhotoView, context: Context) {
    if view.livePhoto !== livePhoto { view.livePhoto = livePhoto }
    if isPlaying && !context.coordinator.wasPlaying {
      view.startPlayback(with: .full)
    } else if !isPlaying && context.coordinator.wasPlaying {
      view.stopPlayback()
    }
    context.coordinator.wasPlaying = isPlaying
  }

  func makeCoordinator() -> Coordinator { Coordinator() }

  class Coordinator {
    var wasPlaying = false
  }
}

// Pinch to zoom and double tap zoomable container
private struct NativeZoomableImageView: UIViewRepresentable {
  let image: UIImage
  let size: CGSize
  let onTap: () -> Void
  let onZoomChanged: (Bool) -> Void

  func makeUIView(context: Context) -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator
    scrollView.maximumZoomScale = 5.0
    scrollView.minimumZoomScale = 1.0
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.backgroundColor = .clear

    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.tag = 100
    scrollView.addSubview(imageView)

    let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
    tapGesture.numberOfTapsRequired = 1
    scrollView.addGestureRecognizer(tapGesture)

    let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
    doubleTapGesture.numberOfTapsRequired = 2
    scrollView.addGestureRecognizer(doubleTapGesture)
    tapGesture.require(toFail: doubleTapGesture)

    return scrollView
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    context.coordinator.onTap = onTap
    context.coordinator.onZoomChanged = onZoomChanged
    if let imageView = uiView.viewWithTag(100) as? UIImageView {
      imageView.image = image
      imageView.frame = CGRect(origin: .zero, size: size)
      uiView.contentSize = size
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(onTap: onTap, onZoomChanged: onZoomChanged)
  }

  class Coordinator: NSObject, UIScrollViewDelegate {
    var onTap: () -> Void
    var onZoomChanged: (Bool) -> Void

    init(onTap: @escaping () -> Void, onZoomChanged: @escaping (Bool) -> Void) {
      self.onTap = onTap
      self.onZoomChanged = onZoomChanged
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      scrollView.viewWithTag(100)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
      onZoomChanged(scrollView.zoomScale > scrollView.minimumZoomScale + 0.01)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
      onZoomChanged(scale > scrollView.minimumZoomScale + 0.01)
    }

    @objc func handleTap() {
      onTap()
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
      guard let scrollView = gesture.view as? UIScrollView else { return }
      if scrollView.zoomScale > 1.0 {
        scrollView.setZoomScale(1.0, animated: true)
      } else {
        let point = gesture.location(in: scrollView)
        let side = max(80, min(scrollView.bounds.width, scrollView.bounds.height) / 2)
        let rect = CGRect(x: point.x - side / 2, y: point.y - side / 2, width: side, height: side)
        scrollView.zoom(to: rect, animated: true)
      }
    }
  }
}

// Info & EXIF Sheet
private struct NativeAssetInfoSheet: View {
  let client: NativeImmichClient
  let device: NativeDeviceLibrary
  let item: NativeGridItem

  @State private var remoteInfo: [String: Any]?
  @State private var loadingInfo = false
  @State private var infoError: String?
  @Environment(\.dismiss) private var dismiss

  private var infoAsset: [String: Any] { remoteInfo ?? [:] }
  private var exif: [String: Any] { infoAsset["exifInfo"] as? [String: Any] ?? [:] }
  private var localAsset: PHAsset? {
    guard let id = item.local?.id else { return nil }
    return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
  }
  private var localResource: PHAssetResource? { localAsset?.getResource() }
  private var resolvedName: String? {
    (infoAsset["originalFileName"] as? String) ?? item.server?.originalFileName ?? localResource?.originalFilename
  }
  private var sizeText: String? {
    let width = (infoAsset["width"] as? NSNumber)?.intValue ?? item.server?.width ?? localAsset?.pixelWidth
    let height = (infoAsset["height"] as? NSNumber)?.intValue ?? item.server?.height ?? localAsset?.pixelHeight
    guard let width, let height, width > 0, height > 0 else { return nil }
    return "\(width) × \(height)"
  }
  private var fileSize: Int64? {
    (exif["fileSizeInByte"] as? NSNumber)?.int64Value ?? item.server?.fileSizeInByte
  }

  var body: some View {
    NavigationView {
      List {
        Section("基本信息") {
          InfoRow(label: "拍摄时间", value: NativeImmichClient.formatChineseDateTime(item.date))
          InfoRow(label: "类型", value: item.isVideo ? "视频" : "照片")
          InfoRow(label: "来源", value: item.server != nil && item.local != nil ? "本机与云端" : (item.local != nil ? "本机" : "云端"))
          InfoRow(label: "副本状态", value: item.server != nil && item.local != nil ? "双端已确认" : (item.server != nil ? "仅云端" : (NativeSyncCacheStore.shared.isMatched(localId: item.local?.id) ? "已匹配，云端信息待载入" : "本机；核验状态按下方显示")))
          if let local = item.local {
            InfoRow(label: "云端核验", value: NativeSyncCacheStore.shared.isMatched(localId: local.id) ? "已确认匹配" : "尚未确认；不能据此判断未上传")
          }
          if let resolvedName { InfoRow(label: "文件名", value: resolvedName) }
          if let sizeText { InfoRow(label: "尺寸", value: sizeText) }
          if let mime = (infoAsset["originalMimeType"] as? String) ?? item.server?.originalMimeType ?? localResource?.uniformTypeIdentifier { InfoRow(label: "格式", value: mime) }
          if let fileSize { InfoRow(label: "文件大小", value: ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)) }
          if let location = locationText { InfoRow(label: "地点", value: location) }
        }

        if let infoError {
          Section("云端详情") { Text(infoError).foregroundColor(.secondary); Button("重试") { Task { await loadInfo() } } }
        } else if loadingInfo {
          Section("云端详情") { ProgressView("正在加载详情…") }
        }

        if !exif.isEmpty {
          Section("拍摄与硬件参数") {
            if let make = exif["make"] as? String { InfoRow(label: "设备品牌", value: make) }
            if let model = exif["model"] as? String { InfoRow(label: "设备型号", value: model) }
            if let lens = exif["lensModel"] as? String { InfoRow(label: "镜头", value: lens) }
            if let fNumber = exif["fNumber"] { InfoRow(label: "光圈", value: "f/\(fNumber)") }
            if let focal = exif["focalLength"] { InfoRow(label: "焦距", value: "\(focal)mm") }
            if let iso = exif["iso"] { InfoRow(label: "ISO", value: "\(iso)") }
            if let exp = exif["exposureTime"] { InfoRow(label: "曝光时间", value: "\(exp)s") }
          }
        }
      }
      .navigationTitle("详细信息")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("完成") { dismiss() } } }
      .task { await loadInfo() }
    }
  }

  private var locationText: String? {
    let latitude = (exif["latitude"] as? NSNumber)?.doubleValue ?? item.server?.latitude ?? localAsset?.location?.coordinate.latitude
    let longitude = (exif["longitude"] as? NSNumber)?.doubleValue ?? item.server?.longitude ?? localAsset?.location?.coordinate.longitude
    guard let latitude, let longitude else { return nil }
    return String(format: "%.5f, %.5f", latitude, longitude)
  }

  @MainActor private func loadInfo() async {
    guard let server = item.server else { return }
    loadingInfo = true
    infoError = nil
    do { remoteInfo = try await client.assetInfo(id: server.id) }
    catch { infoError = error.localizedDescription }
    loadingInfo = false
  }
}

private struct InfoRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack(alignment: .top) {
      Text(label)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .frame(width: 90, alignment: .leading)
      Spacer()
      Text(value)
        .font(.subheadline)
        .foregroundColor(.primary)
        .multilineTextAlignment(.trailing)
    }
  }
}

// MARK: - Server and Sync Settings Sheets

struct NativeServerSettingsSheet: View {
  let client: NativeImmichClient
  let onLogout: () -> Void
  @Environment(\.dismiss) private var dismiss

  @State private var currentUserEmail: String = "正在获取…"
  @State private var currentUserName: String = ""
  @State private var isTestingConnection = false
  @State private var testResult: String? = nil
  @State private var testSuccess: Bool? = nil

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("当前登录账号")) {
          HStack {
            Text("账号邮箱")
            Spacer()
            Text(currentUserEmail)
              .foregroundColor(.secondary)
          }
          if !currentUserName.isEmpty {
            HStack {
              Text("用户昵称")
              Spacer()
              Text(currentUserName)
                .foregroundColor(.secondary)
            }
          }
        }

        Section(header: Text("服务器配置")) {
          HStack {
            Text("服务器地址")
            Spacer()
            Text(client.config.serverUrl)
              .foregroundColor(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          }
          if let deviceId = client.config.deviceId {
            HStack {
              Text("设备标识")
              Spacer()
              Text(deviceId)
                .foregroundColor(.secondary)
            }
          }
          HStack {
            Text("认证方式")
            Spacer()
            Text(client.config.apiKey != nil ? "API Key" : "账号凭据")
              .foregroundColor(.secondary)
          }
        }

        Section(header: Text("连接性测试"), footer: testResult.map { Text($0).foregroundColor(testSuccess == true ? .green : .red) }) {
          Button {
            testServerConnection()
          } label: {
            HStack {
              if isTestingConnection {
                ProgressView().scaleEffect(0.8)
                Text("正在测试连接…")
              } else {
                Text("测试服务器连接性")
              }
            }
          }
          .disabled(isTestingConnection)
        }

        Section(header: Text("账号操作")) {
          Button(role: .destructive) {
            dismiss()
            onLogout()
          } label: {
            HStack {
              Spacer()
              Text("退出当前账号")
              Spacer()
            }
          }
        }
      }
      .navigationTitle("服务器设置")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("完成") { dismiss() }
        }
      }
      .task {
        await loadUserInfo()
      }
    }
  }

  private func loadUserInfo() async {
    do {
      let info = try await client.send(path: "users/me")
      let email = info["email"] as? String ?? "已登录"
      let name = info["name"] as? String ?? ""
      await MainActor.run {
        currentUserEmail = email
        currentUserName = name
      }
    } catch {
      await MainActor.run {
        currentUserEmail = client.config.apiKey != nil ? "API Key 授权" : "无法获取用户信息"
      }
    }
  }

  private func testServerConnection() {
    isTestingConnection = true
    testResult = nil
    testSuccess = nil
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    Task {
      let start = Date()
      do {
        _ = try await client.send(path: "server/ping")
        let latency = Int(Date().timeIntervalSince(start) * 1000)
        await MainActor.run {
          isTestingConnection = false
          testSuccess = true
          testResult = "连接正常：服务器响应成功，延迟约为 \(latency)ms"
          UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
      } catch {
        await MainActor.run {
          isTestingConnection = false
          testSuccess = false
          testResult = "连接失败：\(error.localizedDescription)"
          UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
      }
    }
  }
}

struct NativeSyncSettingsSheet: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  @ObservedObject var cloud: NativeCloudStatus
  @Environment(\.dismiss) private var dismiss

  @AppStorage("backup_enabled") private var syncEnabled = true

  private var verifiedLocalOnlyCount: Int {
    device.assets.filter { cloud.checkedIDs.contains($0.id) && !cloud.failedVerificationIDs.contains($0.id) && cloud.matchedServerIDs[$0.id] == nil }.count
  }

  private var unknownCount: Int {
    device.assets.filter { (!cloud.checkedIDs.contains($0.id) || cloud.failedVerificationIDs.contains($0.id)) && cloud.matchedServerIDs[$0.id] == nil }.count
  }

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("云端状态核验"), footer: Text("此版本仅计算本机原件指纹并查询服务器是否已有匹配资产，不会上传照片。")) {
          Toggle("开启自动核验", isOn: $syncEnabled)
        }

        Section(header: Text("相册与同步状态")) {
          HStack {
            Text("设备已授权照片")
            Spacer()
            Text("\(device.assets.count) 项").foregroundColor(.secondary)
          }
          HStack {
            Text("已匹配云端照片")
            Spacer()
            Text("\(cloud.matchedServerIDs.count) 项").foregroundColor(.secondary)
          }
          HStack {
            Text("已核验但云端无匹配")
            Spacer()
            Text("\(verifiedLocalOnlyCount) 项").foregroundColor(verifiedLocalOnlyCount > 0 ? .orange : .secondary)
          }
          HStack {
            Text("状态未知")
            Spacer()
            Text("\(unknownCount) 项").foregroundColor(unknownCount > 0 ? .secondary : .secondary)
          }
        }

        Section(header: Text("核验")) {
          Button {
            Task {
              await cloud.retry(device.assets, client: client)
            }
          } label: {
            HStack {
              if cloud.isRunning {
                ProgressView().scaleEffect(0.8)
                Text("正在核验中…")
              } else {
                Text("重新核验本地照片")
              }
            }
          }
          .disabled(cloud.isRunning || !syncEnabled)

        }
      }
      .navigationTitle("同步设置")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("完成") { dismiss() }
        }
      }
    }
  }
}

extension Notification.Name {
  static let immichScrollPhotosToBottom = Notification.Name("ImmichScrollPhotosToBottom")
}

extension View {
  @ViewBuilder
  func nativeScrollDisabled(_ disabled: Bool) -> some View {
    if #available(iOS 16.0, *) {
      self.scrollDisabled(disabled)
    } else {
      self
    }
  }
}

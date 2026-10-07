import Combine
import CryptoKit
import Foundation
import Photos
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

private actor NativeThumbnailDiskCache {
  static let shared = NativeThumbnailDiskCache()
  private let directory: URL
  private var writesSincePrune = 0

  private init() {
    directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("ImmichZThumbnails_v2", isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
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

@MainActor
final class NativeImmichClient {
  let config: NativeServerConfig
  private let session: URLSession

  init(config: NativeServerConfig, session: URLSession = .shared) {
    self.config = config
    self.session = session
  }

  static func normalize(_ raw: String) -> String {
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
    let config = NativeServerConfig(serverUrl: normalize(server), apiEndpoint: endpoint, accessToken: token)
    try await NativeImmichClient(config: config).verifySession()
    return config
  }

  static func login(server: String, apiKey: String) async throws -> NativeServerConfig {
    let endpoint = try await discover(server)
    let config = NativeServerConfig(serverUrl: normalize(server), apiEndpoint: endpoint, apiKey: apiKey)
    try await NativeImmichClient(config: config).verifySession()
    return config
  }

  func verifySession() async throws {
    _ = try await send(path: "users/me")
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
    return ids.enumerated().compactMap { index, rawID in
      guard let id = rawID as? String else { return nil }
      let dateString = (dates[safe: index] as? String) ?? (created[safe: index] as? String) ?? bucket.id
      let date = Self.parseISODate(dateString) ?? .distantPast
      return NativeAsset(
        id: id,
        date: date,
        isImage: images[safe: index] as? Bool ?? true,
        isFavorite: favorites[safe: index] as? Bool ?? false,
        thumbhash: hashes[safe: index] as? String
      )
    }
  }

  func originalURL(for asset: NativeAsset) -> URL? {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    return URL(string: base + "/assets/\(asset.id)/original")
  }

  func thumbnailURL(for asset: NativeAsset, size: String = "preview") -> URL? {
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

  private static let isoFormatterWithFractional: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
  }()

  private static let isoFormatterStandard: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime]
    return f
  }()

  static func parseISODate(_ value: String) -> Date? {
    if let d = isoFormatterWithFractional.date(from: value) { return d }
    if let d = isoFormatterStandard.date(from: value) { return d }
    return parseDate(value)
  }

  static func formatChineseDate(_ date: Date, includeDay: Bool = true) -> String {
    let calendar = Calendar.current
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

  private static func parseDate(_ value: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
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

struct NativeAsset: Identifiable {
  let id: String
  let date: Date
  let isImage: Bool
  let isFavorite: Bool
  let thumbhash: String?
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
        do {
          try await NativeImmichClient(config: saved).verifySession()
          config = saved
        } catch {
          if let apiError = error as? NativeAPIError, case .unauthorized = apiError {
            NativeSessionStore.clear()
            restoreError = error.localizedDescription
          } else {
            // Keep credentials across offline or transient server failures.
            restoreError = error.localizedDescription
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
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("使用完整应用", action: onUseFlutter)
        }
      }
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
    do {
      assets = []
      searchFallbackEnabled = false
      searchCursor = nil
      buckets = try await client.timelineBuckets()
      nextBucket = 0
      hasOlder = !buckets.isEmpty
      try await loadNextPage()
      // If the first page of buckets had very few assets, load more to fill view
      while assets.count < 100 && hasOlder {
        try await loadNextPage()
      }
    } catch {
      // Some compatible Immich servers or reverse proxies return a non-JSON
      // timeline response. Keep Photos usable via the standard metadata search.
      do {
        searchFallbackEnabled = true
        searchCursor = nil
        assets = []
        try await loadSearchFallbackPage()
      } catch { self.error = error.localizedDescription }
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
    if buckets.isEmpty {
      await loadInitial()
    } else {
      await loadOlder()
    }
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
      do {
        let bucketAssets = try await client.assets(in: bucket)
        result.append(contentsOf: bucketAssets)
      } catch {
        // Continue with remaining buckets even if one bucket query errors
      }
    }
    nextBucket = end
    hasOlder = nextBucket < buckets.count
    var seen = Set<String>()
    assets = (assets + result).filter { seen.insert($0.id).inserted }.sorted { $0.date < $1.date }
  }
}

struct NativePhotosView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  let onUseFlutter: () -> Void
  let onLogout: () -> Void
  @StateObject private var model: NativeTimelineModel
  @StateObject private var cloud = NativeCloudStatus()
  @State private var columns: Int = 3
  @State private var gestureBaseColumns: Int? = nil
  @State private var cachedDayGroups: [NativeDayGroup] = []
  @State private var selected: NativeAsset?
  @State private var selectedLocal: NativeDeviceAsset?
  @State private var selectedIDs: Set<String> = []
  @State private var isSelecting = false
  @State private var isMagnifying = false
  @State private var dragInitialSelectedIDs: Set<String> = []
  @State private var dragSelectMode: Bool = true // true = selecting, false = deselecting
  @State private var dragStartLocation: CGPoint? = nil
  @State private var dragStartAssetID: String? = nil
  @State private var itemBounds: [String: CGRect] = [:]
  @State private var hasInitialScrolled = false
  @State private var didInitialPosition = false
  @State private var initialScrollVisible = false
  @State private var loadingOlderAnchor: String?
  @State private var lastScrollToBottomTime: Date = .distantPast
  private let bottomAnchor = "timeline-bottom-anchor"

  init(client: NativeImmichClient, device: NativeDeviceLibrary, onUseFlutter: @escaping () -> Void, onLogout: @escaping () -> Void) {
    self.client = client
    self.device = device
    self.onUseFlutter = onUseFlutter
    self.onLogout = onLogout
    _model = StateObject(wrappedValue: NativeTimelineModel(client: client))
  }

  private var firstGroupDatesInMonth: Set<Date> {
    var seenYearMonths = Set<Int>()
    var result = Set<Date>()
    let calendar = Calendar.current
    for group in cachedDayGroups {
      let year = calendar.component(.year, from: group.date)
      let month = calendar.component(.month, from: group.date)
      let key = year * 100 + month
      if seenYearMonths.insert(key).inserted {
        result.insert(group.date)
      }
    }
    return result
  }

  private func formatDateBadge(for group: NativeDayGroup) -> String {
    let isFirstInMonth = firstGroupDatesInMonth.contains(group.date)
    return NativeImmichClient.formatChineseDate(group.date, includeDay: !isFirstInMonth)
  }

  var body: some View {
    NavigationView {
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 4) {
            if model.hasOlder && !model.assets.isEmpty {
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
            if model.assets.isEmpty && (model.isLoading || device.isLoading) {
              VStack(spacing: 10) {
                ProgressView()
                Text("正在加载照片…")
                  .font(.caption).foregroundColor(.secondary)
              }
              .frame(maxWidth: .infinity, minHeight: 240)
            }
            if !model.isLoading && !device.isLoading && model.error == nil &&
                cachedDayGroups.isEmpty && (device.assets.isEmpty || !device.authorized) {
              VStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                  .font(.largeTitle).foregroundColor(.secondary)
                Text("暂无照片").font(.headline)
                Text("当前账号中没有可显示的照片。")
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
                          .preference(key: NativeItemFramePreferenceKey.self, value: [entry.id: geo.frame(in: .named("photosScrollSpace"))])
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
                          selected = entry.server
                          selectedLocal = entry.local
                        }
                      }
                      .onLongPressGesture(minimumDuration: 0.32, maximumDistance: 15) {
                        guard !isMagnifying else { return }
                        enterSelection(startingWith: entry.id)
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
        .coordinateSpace(name: "photosScrollSpace")
        .nativeScrollDisabled(isSelecting)
        .onPreferenceChange(NativeItemFramePreferenceKey.self) { frames in
          itemBounds = frames
        }
        .simultaneousGesture(
          DragGesture(minimumDistance: 8, coordinateSpace: .named("photosScrollSpace"))
            .onChanged { gesture in
              guard isSelecting else { return }
              handle2DDragSelection(at: gesture.location)
            }
            .onEnded { _ in
              finishDragSelection()
            }
        )
        .background(Color(uiColor: .systemBackground))
        .simultaneousGesture(
          MagnificationGesture()
            .onChanged { value in
              guard !isSelecting else { return }
              if !isMagnifying {
                isMagnifying = true
              }
              let base = gestureBaseColumns ?? columns
              if gestureBaseColumns == nil {
                gestureBaseColumns = base
              }
              let deadzone: Double = 0.12
              var effectiveValue = value
              if value > 1.0 {
                if value < 1.0 + deadzone { return }
                effectiveValue = 1.0 + (value - 1.0 - deadzone)
              } else {
                if value > 1.0 - deadzone { return }
                effectiveValue = 1.0 - (1.0 - deadzone - value)
              }
              let delta: Double
              if effectiveValue >= 1.0 {
                delta = -(effectiveValue - 1.0) * 4.0
              } else {
                delta = (1.0 / max(0.08, effectiveValue) - 1.0) * 4.0
              }
              let target = min(15, max(1, Int(round(Double(base) + delta))))
              if target != columns {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                  columns = target
                }
              }
            }
            .onEnded { _ in
              gestureBaseColumns = nil
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isMagnifying = false
              }
            }
        )
        .onChange(of: cloud.matchedServerIDs) { _ in rebuildDayGroups() }
        .refreshable {
          await model.loadInitial()
          rebuildDayGroups()
          Task { await cloud.check(device.assets, client: client) }
          scrollToBottom(proxy: proxy, animated: false)
        }
        .onChange(of: device.assets.count) { _ in
          rebuildDayGroups()
          Task { await cloud.check(device.assets, client: client) }
          if !hasInitialScrolled && !cachedDayGroups.isEmpty {
            scrollToBottom(proxy: proxy, animated: false)
          }
        }
        .onAppear {
          rebuildDayGroups()
          if model.assets.isEmpty && !model.isLoading {
            Task {
              await model.loadInitial()
              rebuildDayGroups()
              await cloud.check(device.assets, client: client)
              scrollToBottom(proxy: proxy, animated: false)
            }
          } else {
            Task { await cloud.check(device.assets, client: client) }
            if !cachedDayGroups.isEmpty && !hasInitialScrolled {
              scrollToBottom(proxy: proxy, animated: false)
            }
          }
        }
        .onChange(of: model.assets.count) { _ in
          rebuildDayGroups()
          if !hasInitialScrolled && !cachedDayGroups.isEmpty {
            scrollToBottom(proxy: proxy, animated: false)
          }
        }
        .onReceive(NotificationCenter.default.publisher(for: .immichScrollPhotosToBottom)) { _ in
          let now = Date()
          guard now.timeIntervalSince(lastScrollToBottomTime) > 0.25 else { return }
          lastScrollToBottomTime = now
          scrollToBottom(proxy: proxy, animated: true)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
          if !device.authorized {
            Button("允许访问本机照片（可选）") { Task { await device.requestAccess() } }.padding(6)
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
        .navigationTitle("照片")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            if isSelecting {
              Button("取消") { clearSelection() }
            } else {
              HStack(spacing: 6) {
                Text("\(model.assets.count) 项").font(.caption).foregroundColor(.secondary)
                if model.isLoading {
                  ProgressView()
                    .scaleEffect(0.7)
                }
              }
            }
          }
          ToolbarItem(placement: .principal) {
            if isSelecting {
              Text("已选 \(selectedIDs.count) 项").font(.headline)
            }
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            if isSelecting {
              Button("全选") {
                selectedIDs = Set(cachedDayGroups.flatMap(\.assets).map(\.id))
              }
            } else {
              HStack(spacing: 8) {
                Menu {
                  Picker("网格密度", selection: $columns) {
                    Text("1 列 · 超大").tag(1)
                    Text("2 列 · 大图").tag(2)
                    Text("3 列 · 标准").tag(3)
                    Text("4 列 · 紧凑").tag(4)
                    Text("5 列 · 密集").tag(5)
                    Text("7 列 · 微缩").tag(7)
                    Text("10 列 · 概览").tag(10)
                    Text("15 列 · 全景").tag(15)
                  }
                } label: {
                  Image(systemName: "square.grid.3x3")
                }
                Menu {
                  Button(action: {
                    scrollToBottom(proxy: proxy, animated: true)
                  }) {
                    Label("回到最新", systemImage: "arrow.down.to.line")
                  }
                  Button(action: {
                    Task {
                      await model.loadInitial()
                      rebuildDayGroups()
                      await cloud.check(device.assets, client: client)
                      scrollToBottom(proxy: proxy, animated: false)
                    }
                  }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                  }
                  Button(action: onUseFlutter) {
                    Label("使用完整应用", systemImage: "square.grid.2x2")
                  }
                  Button(action: {
                    cloud.clearCache()
                    onLogout()
                  }) {
                    Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                  }
                } label: { Image(systemName: "ellipsis.circle") }
              }
            }
          }
        }
        .sheet(item: $selected) { NativeAssetViewer(client: client, asset: $0) }
        .sheet(item: $selectedLocal) { NativeDeviceViewer(asset: $0) }
      }
    }
    .navigationViewStyle(.stack)
  }

  private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
    let isFirst = !hasInitialScrolled
    hasInitialScrolled = true
    if isFirst {
      // First scroll: position immediately without delay, then reveal
      withAnimation(.none) {
        proxy.scrollTo(bottomAnchor, anchor: .bottom)
      }
      // Reveal content after the scroll position is committed
      DispatchQueue.main.async {
        withAnimation(.none) {
          proxy.scrollTo(bottomAnchor, anchor: .bottom)
        }
        initialScrollVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          didInitialPosition = true
        }
      }
    } else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        if animated {
          withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(bottomAnchor, anchor: .bottom)
          }
        } else {
          withAnimation(.none) {
            proxy.scrollTo(bottomAnchor, anchor: .bottom)
          }
        }
        if !self.didInitialPosition {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.didInitialPosition = true
          }
        }
      }
    }
  }

  private func requestOlder(proxy: ScrollViewProxy) {
    guard loadingOlderAnchor == nil, model.hasOlder, !model.isLoading, didInitialPosition else { return }
    let anchor = cachedDayGroups.first?.assets.first?.id
    loadingOlderAnchor = anchor ?? "pending"
    Task {
      await model.loadOlder()
      if let anchor {
        await Task.yield()
        withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) }
      }
      try? await Task.sleep(nanoseconds: 300_000_000)
      loadingOlderAnchor = nil
    }
  }

  private func rebuildDayGroups() {
    let matchedLocalToServer = cloud.matchedServerIDs
    let serverAssetByID = Dictionary(model.assets.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

    var usedServerIDs = Set<String>()
    var merged: [NativeGridItem] = []
    merged.reserveCapacity(model.assets.count + device.assets.count)

    // 1. Process all local assets from the device
    for localAsset in device.assets {
      if let serverID = matchedLocalToServer[localAsset.id], let serverAsset = serverAssetByID[serverID] {
        // Matched and server asset is loaded -> unified single item
        merged.append(NativeGridItem(server: serverAsset, local: localAsset))
        usedServerIDs.insert(serverAsset.id)
      } else {
        // Local only, or server asset not yet loaded in model
        merged.append(NativeGridItem(server: nil, local: localAsset))
      }
    }

    // 2. Process all server assets
    for serverAsset in model.assets {
      if !usedServerIDs.contains(serverAsset.id) {
        // Server asset not already merged with a local asset -> display as remote item
        merged.append(NativeGridItem(server: serverAsset, local: nil))
      }
    }

    merged.sort { lhs, rhs in
      if lhs.date == rhs.date { return lhs.id < rhs.id }
      return lhs.date < rhs.date
    }
    var grouped: [Date: [NativeGridItem]] = [:]
    for item in merged {
      let date = Calendar.current.startOfDay(for: item.date)
      grouped[date, default: []].append(item)
    }
    cachedDayGroups = grouped.keys.sorted().map { date in
      NativeDayGroup(date: date, assets: grouped[date] ?? [])
    }
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
    selectedIDs.removeAll()
    finishDragSelection()
  }

  private func cloudSymbol(for entry: NativeGridItem) -> String {
    entry.cloudSymbol(matchedServerIDs: cloud.matchedServerIDs)
  }

  private func cloudDescription(for entry: NativeGridItem) -> String {
    let typeName = entry.isVideo ? "视频" : "照片"
    if let local = entry.local {
      if entry.server != nil || cloud.matchedServerIDs[local.id] != nil {
        return "已同步\(typeName)"
      } else {
        return "未同步\(typeName)"
      }
    } else {
      return "云端\(typeName)"
    }
  }
}

private struct NativeDayGroup {
  let date: Date
  let assets: [NativeGridItem]
}

private struct NativeItemFramePreferenceKey: PreferenceKey {
  static var defaultValue: [String: CGRect] = [:]
  static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}

private enum NativeThumbnailCache {
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

struct NativeAssetViewer: View {
  let client: NativeImmichClient
  let asset: NativeAsset
  @Environment(\.dismiss) private var dismiss
  @State private var image: UIImage?

  var body: some View {
    NavigationView {
      ZStack {
        Color.black.ignoresSafeArea()
        if !asset.isImage {
          Text("视频播放尚未迁移；请从“使用完整应用”打开视频。")
            .foregroundColor(.white).multilineTextAlignment(.center).padding()
        } else if let image { Image(uiImage: image).resizable().scaledToFit() }
        else { ProgressView().tint(.white) }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("关闭") { dismiss() }.foregroundColor(.white)
        }
        ToolbarItem(placement: .principal) {
          Text(NativeImmichClient.formatChineseDate(asset.date)).foregroundColor(.white)
        }
      }
      .task {
        guard asset.isImage, let url = client.originalURL(for: asset) else { return }
        if let data = try? await client.imageData(for: url) { image = UIImage(data: data) }
      }
    }
    .navigationViewStyle(.stack)
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

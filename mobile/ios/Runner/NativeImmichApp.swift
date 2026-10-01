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
      return NativeBucket(id: String(id.prefix(10)), count: row["count"] as? Int ?? 0)
    }
  }

  func assets(in bucket: NativeBucket) async throws -> [NativeAsset] {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard var components = URLComponents(string: base + "/timeline/bucket") else { throw NativeAPIError.invalidServer }
    // v3.2.4 /timeline/bucket accepts the YYYY-MM-DD bucket identifier.
    components.queryItems = [
      URLQueryItem(name: "timeBucket", value: bucket.id),
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
      let date = ISO8601DateFormatter().date(from: dateString) ?? Self.parseDate(dateString) ?? .distantPast
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

  func thumbnailURL(for asset: NativeAsset) -> URL? {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    var components = URLComponents(string: base + "/assets/\(asset.id)/thumbnail")
    components?.queryItems = [URLQueryItem(name: "size", value: "thumbnail")]
    return components?.url
  }

  func imageData(for url: URL) async throws -> Data {
    guard let endpoint = URL(string: config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")),
          url.scheme == endpoint.scheme, url.host == endpoint.host, url.port == endpoint.port,
          url.path.hasPrefix(endpoint.path + "/") else { throw NativeAPIError.invalidServer }
    var request = URLRequest(url: url)
    applyAuth(to: &request)
    let (data, response) = try await nativeData(for: request, using: session)
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

  private static func parseDate(_ value: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", "yyyy-MM-dd'T'HH:mm:ssXXXXX", "yyyy-MM-dd"] {
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
  private let pageSize = 4

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
    for bucket in page { result.append(contentsOf: try await client.assets(in: bucket)) }
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
  @State private var zoom: CGFloat = 1
  @State private var zoomStart: CGFloat = 1
  @State private var selected: NativeAsset?
  @State private var selectedLocal: NativeDeviceAsset?
  @State private var loadingOlderAnchor: String?
  @State private var initialPositioned = false

  init(client: NativeImmichClient, device: NativeDeviceLibrary, onUseFlutter: @escaping () -> Void, onLogout: @escaping () -> Void) {
    self.client = client
    self.device = device
    self.onUseFlutter = onUseFlutter
    self.onLogout = onLogout
    _model = StateObject(wrappedValue: NativeTimelineModel(client: client))
  }

  private var minimumTile: CGFloat { min(420, max(24, 92 * zoom)) }
  private let bottomAnchor = "timeline-bottom-anchor"

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(spacing: 2) {
              if model.hasOlder && !model.assets.isEmpty {
                ProgressView()
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 16)
                  .id("older-loader")
                  .onAppear { if initialPositioned { requestOlder(proxy: proxy) } }
              }
              ForEach(dayGroups, id: \.date) { group in
                LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumTile), spacing: 2)], spacing: 2) {
                    ForEach(group.assets) { entry in
                      Button {
                        selected = entry.server
                        selectedLocal = entry.local
                      } label: {
                        Group {
                          if let asset = entry.server { NativeThumbnail(client: client, asset: asset) }
                          else if let asset = entry.local { NativeDeviceThumbnail(asset: asset) }
                        }
                        .frame(width: tileWidth(in: geometry.size.width), height: tileWidth(in: geometry.size.width))
                        .clipped()
                        .overlay(alignment: .topLeading) {
                          if entry.id == group.assets.first?.id {
                            Text(group.date, style: .date).font(.caption2).bold()
                              .foregroundColor(.white).lineLimit(1).minimumScaleFactor(0.6)
                              .padding(3).background(.black.opacity(0.65)).allowsHitTesting(false)
                          }
                        }
                        .overlay(alignment: .bottomTrailing) {
                          Image(systemName: cloudSymbol(for: entry))
                            .font(.system(size: minimumTile < 44 ? 10 : 15, weight: .semibold))
                            .foregroundColor(.white).shadow(color: .black, radius: 2)
                            .padding(3)
                        }
                        .accessibilityLabel("\(entry.date.formatted()), \(cloudDescription(for: entry))")
                      }
                      .buttonStyle(.plain)
                      .id(entry.id)
                    }
                  }
              }
              // The anchor is the final item, never below permission/error banners.
              Color.clear.frame(height: 1).id(bottomAnchor)
            }
          }
          .background(Color(uiColor: .systemBackground))
          .simultaneousGesture(MagnificationGesture()
            .onChanged { value in zoom = min(4.5, max(0.27, zoomStart * value)) }
            .onEnded { _ in zoomStart = zoom })
          .refreshable {
            cloud.reset()
            await model.loadInitial()
            Task { await cloud.check(device.assets, client: client) }
            await Task.yield()
            withAnimation(.none) { proxy.scrollTo(bottomAnchor, anchor: .bottom) }
          }
          .onChange(of: device.assets.count) { _ in
            Task { await cloud.check(device.assets, client: client) }
            guard !initialPositioned, !mergedAssets.isEmpty else { return }
            DispatchQueue.main.async {
              proxy.scrollTo(bottomAnchor, anchor: .bottom)
              initialPositioned = true
            }
          }
          .onAppear {
            if !initialPositioned && !mergedAssets.isEmpty {
              DispatchQueue.main.async {
                proxy.scrollTo(bottomAnchor, anchor: .bottom)
                initialPositioned = true
              }
            }
            guard model.assets.isEmpty, !model.isLoading else { return }
            Task {
              await model.loadInitial()
              if !mergedAssets.isEmpty && !initialPositioned {
                DispatchQueue.main.async {
                  proxy.scrollTo(bottomAnchor, anchor: .bottom)
                  initialPositioned = true
                }
              }
              await cloud.check(device.assets, client: client)
            }
          }
        }
      }
      .safeAreaInset(edge: .bottom, spacing: 0) {
        if !device.authorized {
          Button("允许访问本机照片（可选）") { Task { await device.requestAccess() } }.padding(6)
        }
        if model.isLoading { ProgressView().padding(6) }
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
          Text("\(model.assets.count) 项").font(.caption).foregroundColor(.secondary)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button(action: { Task { cloud.reset(); await model.loadInitial(); await cloud.check(device.assets, client: client) } }) {
              Label("刷新", systemImage: "arrow.clockwise")
            }
            Button(action: onUseFlutter) {
              Label("使用完整应用", systemImage: "square.grid.2x2")
            }
            Button(action: onLogout) {
              Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
            }
          } label: { Image(systemName: "ellipsis.circle") }
        }
      }
      .sheet(item: $selected) { asset in
        NativeAssetViewer(client: client, asset: asset)
      }
      .sheet(item: $selectedLocal) { NativeDeviceViewer(asset: $0) }
    }
    .navigationViewStyle(.stack)
    // Reflow only when the adaptive column count changes; animating every cell
    // during each pinch sample causes large timelines to stutter.
    .transaction { $0.disablesAnimations = true }
  }

  private var matchedServerIDs: Set<String> { Set(cloud.matchedServerIDs.values) }

  private var mergedAssets: [NativeGridItem] {
    (model.assets.filter { !matchedServerIDs.contains($0.id) }
      .map { NativeGridItem(server: $0, local: nil) }
      + device.assets.map { NativeGridItem(server: nil, local: $0) })
      .sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }
  }

  private var dayGroups: [NativeDayGroup] {
    let groups = Dictionary(grouping: mergedAssets) { Calendar.current.startOfDay(for: $0.date) }
    return groups.keys.sorted().map { NativeDayGroup(date: $0, assets: groups[$0] ?? []) }
  }

  private func cloudSymbol(for entry: NativeGridItem) -> String {
    guard let local = entry.local else { return "cloud" }
    if cloud.matchedServerIDs[local.id] != nil { return "checkmark.icloud" }
    return cloud.checkedIDs.contains(local.id) ? "icloud.slash" : "questionmark.circle"
  }

  private func cloudDescription(for entry: NativeGridItem) -> String {
    guard let local = entry.local else { return "仅服务器" }
    if cloud.matchedServerIDs[local.id] != nil { return "已上传并存在于本机" }
    return cloud.checkedIDs.contains(local.id) ? "未上传" : "上传状态未核实"
  }

  private func tileWidth(in width: CGFloat) -> CGFloat {
    let gap: CGFloat = 2
    let columns = max(1, Int((width + gap) / (minimumTile + gap)))
    return (width - CGFloat(columns - 1) * gap) / CGFloat(columns)
  }

  private func requestOlder(proxy: ScrollViewProxy) {
    guard loadingOlderAnchor == nil, model.hasOlder, !model.isLoading else { return }
    let anchor = mergedAssets.first?.id
    loadingOlderAnchor = anchor ?? "pending"
    Task {
      await model.loadOlder()
      if let anchor {
        await Task.yield()
        withAnimation(.none) { proxy.scrollTo(anchor, anchor: .top) }
      }
      loadingOlderAnchor = nil
    }
  }
}

private struct NativeDayGroup {
  let date: Date
  let assets: [NativeGridItem]
}

private enum NativeThumbnailCache {
  static let images: NSCache<NSString, UIImage> = {
    let cache = NSCache<NSString, UIImage>()
    cache.countLimit = 450
    cache.totalCostLimit = 100 * 1024 * 1024
    return cache
  }()
}

struct NativeThumbnail: View {
  let client: NativeImmichClient
  let asset: NativeAsset
  @State private var image: UIImage?

  var body: some View {
    Group {
      if let image {
        Image(uiImage: image).resizable().scaledToFill()
      } else {
        Rectangle().fill(Color(uiColor: .secondarySystemBackground))
          .overlay { ProgressView().scaleEffect(0.7) }
      }
    }
    .task(id: asset.id) {
      let key = NSString(string: "\(client.config.serverUrl):\(asset.id)")
      if let cached = NativeThumbnailCache.images.object(forKey: key) { image = cached; return }
      guard let url = client.thumbnailURL(for: asset) else { return }
      do {
        let data = try await client.imageData(for: url)
        guard !Task.isCancelled, let decoded = UIImage(data: data) else { return }
        NativeThumbnailCache.images.setObject(decoded, forKey: key, cost: data.count)
        image = decoded
      } catch { image = nil }
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
          Text(asset.date, style: .date).foregroundColor(.white)
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

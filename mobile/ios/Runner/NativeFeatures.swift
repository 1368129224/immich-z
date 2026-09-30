import Foundation
import Photos
import SwiftUI

// First native vertical slice against the official Immich v3.2.4 OpenAPI.
// The complete Flutter app remains available for features not yet ported.

@MainActor
final class NativeDeviceLibrary: ObservableObject {
  @Published private(set) var authorized = false
  @Published private(set) var assets: [NativeDeviceAsset] = []
  @Published private(set) var albums: [NativeDeviceAlbum] = []

  init() { refresh() }

  func requestAccess() async {
    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    if status == .authorized || status == .limited { refresh() }
  }

  func refresh() {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    authorized = status == .authorized || status == .limited
    guard authorized else { assets = []; albums = []; return }
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    let results = PHAsset.fetchAssets(with: options)
    var entries: [NativeDeviceAsset] = []
    results.enumerateObjects { item, _, _ in
      entries.append(NativeDeviceAsset(id: item.localIdentifier, date: item.creationDate ?? .distantPast, isVideo: item.mediaType == .video))
    }
    assets = entries
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    var localAlbums: [NativeDeviceAlbum] = []
    collections.enumerateObjects { collection, _, _ in
      let count = PHAsset.fetchAssets(in: collection, options: nil).count
      localAlbums.append(NativeDeviceAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "未命名", count: count))
    }
    albums = localAlbums.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
  }

  func assets(in album: NativeDeviceAlbum) -> [NativeDeviceAsset] {
    guard let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [album.id], options: nil).firstObject else { return [] }
    let results = PHAsset.fetchAssets(in: collection, options: nil)
    let ids = Set((0..<results.count).map { results.object(at: $0).localIdentifier })
    return assets.filter { ids.contains($0.id) }
  }
}

struct NativeDeviceAsset: Identifiable {
  let id: String
  let date: Date
  let isVideo: Bool
}

struct NativeDeviceAlbum: Identifiable {
  let id: String
  let name: String
  let count: Int
}

struct NativeDeviceThumbnail: View {
  let asset: NativeDeviceAsset
  @State private var image: UIImage?
  var body: some View {
    Group {
      if let image { Image(uiImage: image).resizable().scaledToFill() }
      else { Rectangle().fill(Color(uiColor: .secondarySystemBackground)) }
    }
    .task(id: asset.id) {
      guard let source = PHAsset.fetchAssets(withLocalIdentifiers: [asset.id], options: nil).firstObject else { return }
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = false
      options.deliveryMode = .opportunistic
      PHImageManager.default().requestImage(for: source, targetSize: CGSize(width: 240, height: 240), contentMode: .aspectFill, options: options) { result, _ in
        Task { @MainActor in image = result }
      }
    }
  }
}

struct NativeDeviceViewer: View {
  let asset: NativeDeviceAsset
  @Environment(\.dismiss) private var dismiss
  @State private var image: UIImage?
  var body: some View {
    NavigationView {
      ZStack {
        Color.black.ignoresSafeArea()
        if let image { Image(uiImage: image).resizable().scaledToFit() }
        else { ProgressView().tint(.white) }
      }
      .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("关闭") { dismiss() } } }
      .task {
        guard let source = PHAsset.fetchAssets(withLocalIdentifiers: [asset.id], options: nil).firstObject else { return }
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: source, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { result, _ in
          Task { @MainActor in image = result }
        }
      }
    }
  }
}

struct NativeDeviceGrid: View {
  let title: String
  let assets: [NativeDeviceAsset]
  @State private var zoom: CGFloat = 1
  @State private var startZoom: CGFloat = 1
  @State private var selected: NativeDeviceAsset?
  @State private var positioned = false
  private let bottom = "device-bottom"

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 4) {
            let groups = Dictionary(grouping: assets) { Calendar.current.startOfDay(for: $0.date) }
            ForEach(groups.keys.sorted(), id: \.self) { day in
              Text(day, style: .date).font(.headline).padding(.horizontal)
              LazyVGrid(columns: [GridItem(.adaptive(minimum: min(320, max(72, 120 * zoom))), spacing: 2)], spacing: 2) {
                ForEach(groups[day] ?? []) { asset in
                  Button { selected = asset } label: {
                    NativeDeviceThumbnail(asset: asset)
                      .frame(height: max(72, min(320, 120 * zoom)))
                      .clipped()
                      .overlay(alignment: .bottomTrailing) {
                        if asset.isVideo { Image(systemName: "video.fill").foregroundColor(.white).padding(5) }
                      }
                  }
                  .buttonStyle(.plain)
                  .accessibilityLabel("设备照片，\(asset.date.formatted())")
                }
              }
            }
            Color.clear.frame(height: 1).id(bottom)
          }
        }
        .simultaneousGesture(MagnificationGesture()
          .onChanged { zoom = min(2.7, max(0.6, startZoom * $0)) }
          .onEnded { _ in startZoom = zoom })
        .onChange(of: assets.count) { _ in
          guard !positioned, !assets.isEmpty else { return }
          proxy.scrollTo(bottom, anchor: .bottom)
          positioned = true
        }
        .onAppear {
          if !assets.isEmpty && !positioned { proxy.scrollTo(bottom, anchor: .bottom); positioned = true }
        }
      }
    }
    .sheet(item: $selected) { NativeDeviceViewer(asset: $0) }
    .navigationTitle(title)
  }
}

struct NativeServerAlbum: Identifiable {
  let id: String
  let name: String
  let count: Int
}

struct NativeSearchPage {
  let assets: [NativeAsset]
  let next: String?
}

extension NativeImmichClient {
  func searchPage(query: String? = nil, albumId: String? = nil, cursor: String? = nil, filter: [String: Any] = [:]) async throws -> NativeSearchPage {
    var terms = filter
    if let albumId { terms["albumIds"] = ["any": [albumId]] }
    if let query, !query.isEmpty { terms["originalFileName"] = ["like": query] }
    var payload: [String: Any] = [
      "size": 100,
      "orderBy": ["field": "fileCreatedAt", "direction": "desc"],
    ]
    if !terms.isEmpty { payload["filter"] = terms }
    if let cursor { payload["cursor"] = cursor }
    let result = try await send(path: "search/metadata", method: "POST", body: payload)
    guard let page = result["assets"] as? [String: Any], let items = page["items"] as? [[String: Any]] else { throw NativeFeatureError.badResponse }
    let assets = items.compactMap { item -> NativeAsset? in
      guard let id = item["id"] as? String else { return nil }
      let dateText = (item["localDateTime"] as? String) ?? (item["fileCreatedAt"] as? String) ?? ""
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      let date = formatter.date(from: dateText) ?? ISO8601DateFormatter().date(from: dateText) ?? .distantPast
      return NativeAsset(id: id, date: date, isImage: (item["type"] as? String) != "VIDEO", isFavorite: item["isFavorite"] as? Bool ?? false, thumbhash: item["thumbhash"] as? String)
    }
    return NativeSearchPage(assets: assets, next: page["nextCursor"] as? String)
  }

  func serverAlbums() async throws -> [NativeServerAlbum] {
    // /albums returns an array, unlike JSON-object endpoints.
    let base = config.apiEndpoint ?? (NativeImmichClient.normalize(config.serverUrl) + "/api")
    guard let url = URL(string: base + "/albums") else { throw NativeFeatureError.badResponse }
    var request = URLRequest(url: url)
    if let token = config.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
    if let key = config.apiKey { request.setValue(key, forHTTPHeaderField: "x-api-key") }
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw NativeFeatureError.badResponse }
    guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { throw NativeFeatureError.badResponse }
    return rows.compactMap { row in
      guard let id = row["id"] as? String, let name = row["albumName"] as? String else { return nil }
      return NativeServerAlbum(id: id, name: name, count: row["assetCount"] as? Int ?? 0)
    }
  }
}

private enum NativeFeatureError: LocalizedError {
  case badResponse
  var errorDescription: String? { "服务器返回了无法识别的数据。" }
}

@MainActor
private final class NativeResultsModel: ObservableObject {
  @Published var assets: [NativeAsset] = []
  @Published var loading = false
  @Published var error: String?
  @Published var next: String?
  private var cursors = Set<String>()
  private let client: NativeImmichClient
  init(_ client: NativeImmichClient) { self.client = client }

  func load(query: String? = nil, albumId: String? = nil, filter: [String: Any] = [:], reset: Bool = false) async {
    guard !loading else { return }
    if reset { assets = []; next = nil; cursors = [] }
    else if !assets.isEmpty && next == nil { return }
    if let next, !cursors.insert(next).inserted { self.next = nil; return }
    loading = true
    error = nil
    defer { loading = false }
    do {
      let page = try await client.searchPage(query: query, albumId: albumId, cursor: next, filter: filter)
      var ids = Set(assets.map(\.id))
      assets += page.assets.filter { ids.insert($0.id).inserted }
      next = page.assets.isEmpty || page.next == next ? nil : page.next
    } catch { self.error = error.localizedDescription }
  }
}

struct NativeResultGrid: View {
  let client: NativeImmichClient
  let assets: [NativeAsset]
  var localAssets: [NativeDeviceAsset] = []
  let hasOlder: Bool
  let loadMore: () -> Void
  @State private var selected: NativeAsset?
  @State private var selectedLocal: NativeDeviceAsset?

  private var merged: [NativeGridItem] {
    (assets.map { NativeGridItem(server: $0, local: nil) } + localAssets.map { NativeGridItem(server: nil, local: $0) })
      .sorted { $0.date == $1.date ? $0.id < $1.id : $0.date < $1.date }
  }
  @State private var positioned = false
  @State private var zoom: CGFloat = 1
  @State private var startZoom: CGFloat = 1
  private let bottom = "results-bottom"

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(spacing: 4) {
            if hasOlder && !assets.isEmpty {
              ProgressView().frame(maxWidth: .infinity).padding(8)
                .onAppear {
                  guard positioned else { return }
                  let anchor = merged.last?.id
                  loadMore()
                  if let anchor { proxy.scrollTo(anchor, anchor: .bottom) }
                }
            }
            let groups = Dictionary(grouping: merged) { Calendar.current.startOfDay(for: $0.date) }
            ForEach(groups.keys.sorted(), id: \.self) { day in
              Text(day, style: .date).font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
              LazyVGrid(columns: [GridItem(.adaptive(minimum: min(320, max(72, 120 * zoom))), spacing: 2)], spacing: 2) {
                ForEach(groups[day] ?? []) { entry in
                  Button {
                    selected = entry.server
                    selectedLocal = entry.local
                  } label: {
                    Group {
                      if let asset = entry.server { NativeThumbnail(client: client, asset: asset) }
                      else if let asset = entry.local { NativeDeviceThumbnail(asset: asset) }
                    }
                    .frame(height: min(320, max(72, 120 * zoom))).clipped()
                    .overlay(alignment: .bottomTrailing) {
                      if entry.local != nil { Image(systemName: "iphone").foregroundColor(.white).padding(4) }
                    }
                  }.buttonStyle(.plain).id(entry.id)
                }
              }
            }
            Color.clear.frame(height: 1).id(bottom)
          }
        }
        .simultaneousGesture(MagnificationGesture()
          .onChanged { zoom = min(2.7, max(0.6, startZoom * $0)) }
          .onEnded { _ in startZoom = zoom })
        .onChange(of: merged.count) { _ in
          guard !positioned, !merged.isEmpty else { return }
          proxy.scrollTo(bottom, anchor: .bottom)
          positioned = true
        }
      }
    }
    .sheet(item: $selected) { NativeAssetViewer(client: client, asset: $0) }
    .sheet(item: $selectedLocal) { NativeDeviceViewer(asset: $0) }
  }
}

struct NativeGridItem: Identifiable {
  let server: NativeAsset?
  let local: NativeDeviceAsset?
  var id: String { server.map { "server:\($0.id)" } ?? "local:\(local?.id ?? "")" }
  var date: Date { server?.date ?? local?.date ?? .distantPast }
}

private struct NativeSearchView: View {
  let client: NativeImmichClient
  @StateObject private var model: NativeResultsModel
  @State private var term = ""
  init(client: NativeImmichClient) {
    self.client = client
    _model = StateObject(wrappedValue: NativeResultsModel(client))
  }
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        TextField("搜索文件名", text: $term).textFieldStyle(.roundedBorder).padding()
          .submitLabel(.search).onSubmit { Task { await model.load(query: term, reset: true) } }
        if let error = model.error { Text(error).foregroundColor(.red); Button("重试") { Task { await model.load(query: term, reset: model.assets.isEmpty) } } }
        if model.assets.isEmpty && !model.loading {
          Spacer()
          Text("输入文件名搜索服务器资产\n更多官方搜索筛选仍在迁移中")
            .multilineTextAlignment(.center).foregroundColor(.secondary)
          Spacer()
        } else {
          NativeResultGrid(client: client, assets: model.assets, hasOlder: model.next != nil) { Task { await model.load(query: term) } }
        }
        if model.loading { ProgressView().padding(8) }
      }
      .navigationTitle("搜索")
    }.navigationViewStyle(.stack)
  }
}

private struct NativeAlbumEntry: Identifiable {
  let id: String
  let title: String
  let server: NativeServerAlbum?
  let device: NativeDeviceAlbum?
  var detail: String { "服务器 \(server?.count ?? 0) · 本机 \(device?.count ?? 0)" }
}

private struct NativeAlbumsView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  @State private var serverAlbums: [NativeServerAlbum] = []
  @State private var error: String?
  @State private var loaded = false

  private var entries: [NativeAlbumEntry] {
    let serverGroups = Dictionary(grouping: serverAlbums) { $0.name.trimmingCharacters(in: .whitespaces).precomposedStringWithCanonicalMapping.folding(options: .caseInsensitive, locale: .current) }
    let localGroups = Dictionary(grouping: device.albums) { $0.name.trimmingCharacters(in: .whitespaces).precomposedStringWithCanonicalMapping.folding(options: .caseInsensitive, locale: .current) }
    let combined = Set(serverGroups.keys).union(localGroups.keys)
    return combined.sorted().flatMap { key -> [NativeAlbumEntry] in
      let remote = serverGroups[key] ?? []
      let local = localGroups[key] ?? []
      if remote.count == 1 && local.count == 1 {
        return [NativeAlbumEntry(id: "pair:\(remote[0].id):\(local[0].id)", title: remote[0].name, server: remote[0], device: local[0])]
      }
      return remote.map { NativeAlbumEntry(id: "server:\($0.id)", title: $0.name, server: $0, device: nil) }
        + local.map { NativeAlbumEntry(id: "local:\($0.id)", title: $0.name, server: nil, device: $0) }
    }
  }

  var body: some View {
    NavigationView {
      List {
        if !device.authorized {
          Button("允许访问设备相册（可选）") { Task { await device.requestAccess() } }
        }
        if let error { Text(error).foregroundColor(.red); Button("重试") { Task { await reload() } } }
        ForEach(entries) { entry in
          NavigationLink(destination: NativeAlbumDetail(client: client, device: device, entry: entry)) {
            VStack(alignment: .leading) {
              Text(entry.title)
              Text(entry.detail).font(.caption).foregroundColor(.secondary)
            }
          }
        }
      }
      .navigationTitle("相册")
      .refreshable { await reload(); device.refresh() }
      .task { if !loaded { loaded = true; await reload() } }
    }.navigationViewStyle(.stack)
  }

  private func reload() async {
    do { serverAlbums = try await client.serverAlbums(); error = nil }
    catch { self.error = error.localizedDescription }
  }
}

private struct NativeAlbumDetail: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  let entry: NativeAlbumEntry
  @StateObject private var model: NativeResultsModel
  init(client: NativeImmichClient, device: NativeDeviceLibrary, entry: NativeAlbumEntry) {
    self.client = client; self.device = device; self.entry = entry
    _model = StateObject(wrappedValue: NativeResultsModel(client))
  }
  var body: some View {
    VStack(spacing: 0) {
      if let error = model.error { Text(error).foregroundColor(.red); Button("重试") { Task { await model.load(albumId: entry.server?.id, reset: model.assets.isEmpty) } } }
      Text("本机成员不会自动上传或分享").font(.footnote).foregroundColor(.secondary)
      NativeResultGrid(client: client, assets: model.assets,
        localAssets: entry.device.map { device.assets(in: $0) } ?? [],
        hasOlder: model.next != nil) {
          if let id = entry.server?.id { Task { await model.load(albumId: id) } }
        }
      if model.loading { ProgressView() }
    }
    .navigationTitle(entry.title)
    .task { if let server = entry.server { await model.load(albumId: server.id, reset: true) } }
  }
}

private struct NativeLibraryView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  var body: some View {
    NavigationView {
      List {
        Section("快捷入口") {
          NavigationLink("收藏") { NativeFilteredView(client: client, title: "收藏", filter: ["isFavorite": ["eq": true]]) }
          NavigationLink("归档") { NativeFilteredView(client: client, title: "归档", filter: ["visibility": ["eq": "archive"]]) }
          NavigationLink("共享链接 · 使用完整应用") { NativeFallbackNote() }
          NavigationLink("回收站 · 使用完整应用") { NativeFallbackNote() }
        }
        Section("集合") {
          NavigationLink("人物 · 使用完整应用") { NativeFallbackNote() }
          NavigationLink("地点 · 使用完整应用") { NativeFallbackNote() }
          NavigationLink("本机") {
            if device.authorized { NativeDeviceGrid(title: "本机照片", assets: device.assets) }
            else { Button("允许访问设备相册") { Task { await device.requestAccess() } } }
          }
          NavigationLink("回忆 · 使用完整应用") { NativeFallbackNote() }
        }
        Section("快捷访问") {
          ForEach(["文件夹", "锁定文件夹", "伙伴共享"], id: \.self) { name in
            NavigationLink("\(name) · 使用完整应用") { NativeFallbackNote() }
          }
        }
      }
      .navigationTitle("资源库")
    }.navigationViewStyle(.stack)
  }
}

private struct NativeFallbackNote: View {
  var body: some View { Text("此功能尚未迁移到 Swift。请返回照片页菜单，选择“使用完整应用”。").padding() }
}

private struct NativeFilteredView: View {
  let client: NativeImmichClient
  let title: String
  let filter: [String: Any]
  @StateObject private var model: NativeResultsModel
  init(client: NativeImmichClient, title: String, filter: [String: Any]) {
    self.client = client; self.title = title; self.filter = filter
    _model = StateObject(wrappedValue: NativeResultsModel(client))
  }
  var body: some View {
    VStack {
      if let error = model.error { Text(error); Button("重试") { Task { await model.load(filter: filter, reset: model.assets.isEmpty) } } }
      NativeResultGrid(client: client, assets: model.assets, hasOlder: model.next != nil) { Task { await model.load(filter: filter) } }
      if model.loading { ProgressView() }
    }
    .navigationTitle(title)
    .task { await model.load(filter: filter, reset: true) }
  }
}

struct NativeTabShell: View {
  let client: NativeImmichClient
  let onUseFlutter: () -> Void
  let onLogout: () -> Void
  @StateObject private var device = NativeDeviceLibrary()
  var body: some View {
    TabView {
      NativePhotosView(client: client, device: device, onUseFlutter: onUseFlutter, onLogout: onLogout)
        .tabItem { Label("照片", systemImage: "photo.on.rectangle") }
      NativeSearchView(client: client)
        .tabItem { Label("搜索", systemImage: "magnifyingglass") }
      NativeAlbumsView(client: client, device: device)
        .tabItem { Label("相册", systemImage: "rectangle.stack") }
      NativeLibraryView(client: client, device: device)
        .tabItem { Label("资源库", systemImage: "square.grid.2x2") }
    }
  }
}

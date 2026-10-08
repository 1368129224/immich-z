import Foundation
import Photos
import SwiftUI
import UIKit

// First native vertical slice against the official Immich v3.2.4 OpenAPI.
// The complete Flutter app remains available for features not yet ported.

@MainActor
final class NativeDeviceLibrary: ObservableObject {
  @Published private(set) var authorized = false
  @Published private(set) var assets: [NativeDeviceAsset] = []
  @Published private(set) var albums: [NativeDeviceAlbum] = []
  @Published private(set) var isLoading = false
  private var refreshGeneration = 0

  init() { refresh() }

  func requestAccess() async {
    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    if status == .authorized || status == .limited { refresh() }
  }

  func refresh() {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    authorized = status == .authorized || status == .limited
    guard authorized else {
      assets = []
      albums = []
      isLoading = false
      return
    }
    refreshGeneration += 1
    let generation = refreshGeneration
    isLoading = true
    Task { [weak self] in
      let library = await Task.detached(priority: .userInitiated) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let results = PHAsset.fetchAssets(with: options)
        var entries: [NativeDeviceAsset] = []
        entries.reserveCapacity(results.count)
        results.enumerateObjects { item, _, _ in
          entries.append(NativeDeviceAsset(
            id: item.localIdentifier,
            date: item.creationDate ?? .distantPast,
            isVideo: item.mediaType == .video,
            contentVersion: Int((item.modificationDate?.timeIntervalSince1970 ?? 0) * 1000)
          ))
        }
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        var localAlbums: [NativeDeviceAlbum] = []
        collections.enumerateObjects { collection, _, _ in
          let count = PHAsset.fetchAssets(in: collection, options: nil).count
          localAlbums.append(NativeDeviceAlbum(id: collection.localIdentifier, name: collection.localizedTitle ?? "未命名", count: count))
        }
        localAlbums.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        return (entries, localAlbums)
      }.value
      guard let self, self.refreshGeneration == generation else { return }
      self.assets = library.0
      self.albums = library.1
      self.isLoading = false
    }
  }

  func assets(in album: NativeDeviceAlbum) -> [NativeDeviceAsset] {
    guard let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [album.id], options: nil).firstObject else { return [] }
    let results = PHAsset.fetchAssets(in: collection, options: nil)
    let ids = Set((0..<results.count).map { results.object(at: $0).localIdentifier })
    return assets.filter { ids.contains($0.id) }
  }

  func firstAsset(in album: NativeDeviceAlbum) -> NativeDeviceAsset? {
    guard let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [album.id], options: nil).firstObject else { return nil }
    let options = PHFetchOptions()
    options.fetchLimit = 1
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    let results = PHAsset.fetchAssets(in: collection, options: options)
    guard let first = results.firstObject else { return nil }
    return assets.first { $0.id == first.localIdentifier } ?? NativeDeviceAsset(
      id: first.localIdentifier,
      date: first.creationDate ?? .distantPast,
      isVideo: first.mediaType == .video,
      contentVersion: Int((first.modificationDate?.timeIntervalSince1970 ?? 0) * 1000)
    )
  }
}

struct NativeDeviceAsset: Identifiable, Sendable {
  let id: String
  let date: Date
  let isVideo: Bool
  let contentVersion: Int
}

struct NativeDeviceAlbum: Identifiable, Sendable {
  let id: String
  let name: String
  let count: Int
}

private enum NativeLocalThumbnailCache {
  static let images: NSCache<NSString, UIImage> = {
    let cache = NSCache<NSString, UIImage>()
    cache.countLimit = 1500
    cache.totalCostLimit = 160 * 1024 * 1024
    return cache
  }()
  static let manager = PHCachingImageManager()
}

struct NativeDeviceThumbnail: View {
  let asset: NativeDeviceAsset
  var columns: Int = 3
  @State private var image: UIImage?

  var body: some View {
    Group {
      if let image { Image(uiImage: image).resizable().scaledToFill() }
      else { Rectangle().fill(Color(uiColor: .secondarySystemBackground)) }
    }
    .task(id: "\(asset.id):\(asset.contentVersion):\(targetDimension)") {
      let dim = targetDimension
      let key = NSString(string: "\(asset.id):\(asset.contentVersion):\(dim)")
      if let cached = NativeLocalThumbnailCache.images.object(forKey: key) {
        image = cached
        return
      }
      guard let source = PHAsset.fetchAssets(withLocalIdentifiers: [asset.id], options: nil).firstObject else { return }
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = true
      options.deliveryMode = .opportunistic
      options.resizeMode = .fast
      let targetSize = CGSize(width: dim, height: dim)
      NativeLocalThumbnailCache.manager.requestImage(
        for: source,
        targetSize: targetSize,
        contentMode: .aspectFill,
        options: options
      ) { result, info in
        guard info?[PHImageCancelledKey] as? Bool != true,
              info?[PHImageErrorKey] == nil,
              let result else { return }
        NativeLocalThumbnailCache.images.setObject(result, forKey: key, cost: Int(result.size.width * result.size.height * 4))
        Task { @MainActor in image = result }
      }
    }
  }

  private var targetDimension: Int {
    if columns <= 2 {
      return 500
    } else if columns <= 4 {
      return 320
    } else if columns <= 7 {
      return 180
    } else {
      return 110
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
  @State private var columns: Int = 3
  @State private var gestureBaseColumns: Int? = nil
  @State private var selected: NativeDeviceAsset?
  @State private var positioned = false
  private let bottom = "device-bottom"

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 4) {
          let groups = Dictionary(grouping: assets) { Calendar.current.startOfDay(for: $0.date) }
          ForEach(groups.keys.sorted(), id: \.self) { day in
            VStack(alignment: .leading, spacing: 2) {
              Text(NativeImmichClient.formatChineseDate(day)).font(.headline).padding(.horizontal)
              let gridSpacing: CGFloat = columns > 7 ? 1 : 2
              LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columns), spacing: gridSpacing) {
                ForEach(groups[day] ?? []) { asset in
                  Button { selected = asset } label: {
                    Color.clear
                      .aspectRatio(1, contentMode: .fit)
                      .overlay(
                        GeometryReader { geo in
                          NativeDeviceThumbnail(asset: asset, columns: columns)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                        }
                      )
                      .clipped()
                      .overlay(alignment: .bottomTrailing) {
                        if asset.isVideo && columns <= 7 {
                          Image(systemName: "play.fill")
                            .font(.system(size: columns > 4 ? 7 : 11, weight: .bold))
                            .foregroundColor(.white).shadow(color: .black, radius: 2)
                            .padding(columns > 4 ? 1.5 : 3)
                        }
                      }
                      .contentShape(Rectangle())
                  }
                  .buttonStyle(.plain)
                  .accessibilityLabel("设备照片，\(asset.date.formatted())")
                }
              }
            }
          }
          Color.clear.frame(height: 1).id(bottom)
        }
      }
      .simultaneousGesture(
        MagnificationGesture()
          .onChanged { value in
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
          }
      )
      .onChange(of: assets.count) { _ in
        guard !positioned, !assets.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
          withAnimation(.none) { proxy.scrollTo(bottom, anchor: .bottom) }
          positioned = true
        }
      }
      .onAppear {
        if !assets.isEmpty && !positioned {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.none) { proxy.scrollTo(bottom, anchor: .bottom) }
            positioned = true
          }
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
  let thumbnailAssetId: String?
}

struct NativeSearchPage {
  let assets: [NativeAsset]
  let next: String?
}

struct NativeExploreSection: Identifiable {
  let id: String
  let items: [NativeExploreTile]
}

struct NativeExploreTile: Identifiable {
  let id: String
  let name: String
  let asset: NativeAsset?
}

extension NativeImmichClient {
  func searchPage(query: String? = nil, albumId: String? = nil, cursor: String? = nil, filter: [String: Any] = [:]) async throws -> NativeSearchPage {
    var terms = filter
    if let albumId { terms["albumIds"] = ["any": [albumId]] }
    if let query, !query.isEmpty {
      terms["or"] = [
        ["originalFileName": ["like": query]],
        ["originalPath": ["like": query]],
        ["description": ["like": query]],
      ]
    }
    var payload: [String: Any] = [
      "size": 100,
      "orderBy": ["field": "fileCreatedAt", "direction": "desc"],
    ]
    if !terms.isEmpty { payload["filter"] = terms }
    if terms["trashedAt"] != nil { payload["withDeleted"] = true }
    if let cursor { payload["cursor"] = cursor }
    let result = try await send(path: "search/metadata", method: "POST", body: payload)
    guard let page = result["assets"] as? [String: Any], let items = page["items"] as? [[String: Any]] else { throw NativeFeatureError.badResponse }
    return NativeSearchPage(assets: items.compactMap(Self.decodeAsset), next: page["nextCursor"] as? String)
  }

  func smartSearch(query: String, page: Int, filter: [String: Any]) async throws -> NativeSearchPage {
    var payload: [String: Any] = ["query": query, "page": page, "size": 100]
    if !filter.isEmpty { payload["filter"] = filter }
    let response = try await send(path: "search/smart", method: "POST", body: payload)
    guard let assets = response["assets"] as? [String: Any], let rows = assets["items"] as? [[String: Any]] else { throw NativeFeatureError.badResponse }
    return NativeSearchPage(assets: rows.compactMap(Self.decodeAsset), next: assets["nextPage"] as? String)
  }

  func explore() async throws -> [NativeExploreSection] {
    let rows = try await nativeArray(path: "search/explore")
    return rows.compactMap { row in
      guard let name = row["fieldName"] as? String, let items = row["items"] as? [[String: Any]] else { return nil }
      return NativeExploreSection(id: name, items: items.compactMap { item in
        guard let value = item["value"] as? String else { return nil }
        return NativeExploreTile(id: value, name: value, asset: (item["data"] as? [String: Any]).flatMap(Self.decodeAsset))
      })
    }
  }

  func nativeArray(path: String) async throws -> [[String: Any]] {
    let base = config.apiEndpoint ?? (NativeImmichClient.normalize(config.serverUrl) + "/api")
    guard let url = URL(string: base + "/" + path) else { throw NativeFeatureError.badResponse }
    var request = URLRequest(url: url)
    if let token = config.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
    if let key = config.apiKey { request.setValue(key, forHTTPHeaderField: "x-api-key") }
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw NativeFeatureError.badResponse }
    guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { throw NativeFeatureError.badResponse }
    return rows
  }

  private static func decodeAsset(_ item: [String: Any]) -> NativeAsset? {
    guard let id = item["id"] as? String else { return nil }
    let dateText = (item["localDateTime"] as? String) ?? (item["fileCreatedAt"] as? String) ?? ""
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let date = formatter.date(from: dateText) ?? ISO8601DateFormatter().date(from: dateText) ?? .distantPast
    return NativeAsset(id: id, date: date, isImage: (item["type"] as? String) != "VIDEO", isFavorite: item["isFavorite"] as? Bool ?? false, thumbhash: item["thumbhash"] as? String)
  }

  func serverAlbums() async throws -> [NativeServerAlbum] {
    let rows = try await nativeArray(path: "albums")
    return rows.compactMap { row in
      guard let id = row["id"] as? String, let name = row["albumName"] as? String else { return nil }
      let thumbId = row["albumThumbnailAssetId"] as? String
      return NativeServerAlbum(id: id, name: name, count: row["assetCount"] as? Int ?? 0, thumbnailAssetId: thumbId)
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
  private var smartPage = 1
  private let client: NativeImmichClient
  init(_ client: NativeImmichClient) { self.client = client }

  func load(query: String? = nil, albumId: String? = nil, filter: [String: Any] = [:], reset: Bool = false) async {
    guard !loading else { return }
    if reset { assets = []; next = nil; cursors = []; smartPage = 1 }
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
    } catch {
      if let next { cursors.remove(next) }
      self.error = error.localizedDescription
    }
  }

  func clear() { assets = []; next = nil; smartPage = 1; cursors = [] }

  func smart(query: String, filter: [String: Any] = [:], reset: Bool = false) async {
    guard !loading else { return }
    if reset { assets = []; next = nil; smartPage = 1 }
    else if !assets.isEmpty && next == nil { return }
    loading = true
    error = nil
    defer { loading = false }
    do {
      let response = try await client.smartSearch(query: query, page: smartPage, filter: filter)
      var ids = Set(assets.map(\.id))
      assets += response.assets.filter { ids.insert($0.id).inserted }
      next = response.next
      if next != nil { smartPage += 1 }
    } catch { self.error = error.localizedDescription }
  }
}

struct NativeResultGrid: View {
  let client: NativeImmichClient
  let assets: [NativeAsset]
  var localAssets: [NativeDeviceAsset] = []
  let hasOlder: Bool
  var isSelectingBinding: Binding<Bool>? = nil
  var selectedIDsBinding: Binding<Set<String>>? = nil
  let loadMore: () -> Void

  @State private var internalIsSelecting = false
  @State private var internalSelectedIDs: Set<String> = []

  @State private var isDragSelecting = false
  @State private var isMagnifying = false
  @State private var columns: Int = 4
  @State private var gestureBaseColumns: Int? = nil

  @State private var dragInitialSelectedIDs: Set<String> = []
  @State private var dragSelectMode: Bool = true
  @State private var dragStartLocation: CGPoint? = nil
  @State private var dragStartAssetID: String? = nil
  @State private var itemBounds: [String: CGRect] = [:]

  @State private var activeViewerItem: NativeGridItem?

  private var isSelecting: Bool {
    isSelectingBinding?.wrappedValue ?? internalIsSelecting
  }

  private var selectedIDs: Set<String> {
    selectedIDsBinding?.wrappedValue ?? internalSelectedIDs
  }

  private func setIsSelecting(_ value: Bool) {
    if let binding = isSelectingBinding {
      binding.wrappedValue = value
    } else {
      internalIsSelecting = value
    }
  }

  private func setSelectedIDs(_ value: Set<String>) {
    if let binding = selectedIDsBinding {
      binding.wrappedValue = value
    } else {
      internalSelectedIDs = value
    }
  }

  init(
    client: NativeImmichClient,
    assets: [NativeAsset],
    localAssets: [NativeDeviceAsset] = [],
    hasOlder: Bool,
    isSelecting: Binding<Bool>? = nil,
    selectedIDs: Binding<Set<String>>? = nil,
    loadMore: @escaping () -> Void
  ) {
    self.client = client
    self.assets = assets
    self.localAssets = localAssets
    self.hasOlder = hasOlder
    self.isSelectingBinding = isSelecting
    self.selectedIDsBinding = selectedIDs
    self.loadMore = loadMore
  }

  private var merged: [NativeGridItem] {
    let matched = NativeSyncCacheStore.shared.matchedServerIDs
    let serverById = Dictionary(assets.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

    var usedServerIDs = Set<String>()
    var items: [NativeGridItem] = []
    items.reserveCapacity(assets.count + localAssets.count)

    for localAsset in localAssets {
      if let serverID = matched[localAsset.id], let serverAsset = serverById[serverID] {
        items.append(NativeGridItem(server: serverAsset, local: localAsset))
        usedServerIDs.insert(serverAsset.id)
      } else {
        items.append(NativeGridItem(server: nil, local: localAsset))
      }
    }

    for serverAsset in assets {
      if !usedServerIDs.contains(serverAsset.id) {
        items.append(NativeGridItem(server: serverAsset, local: nil))
      }
    }

    return items.sorted { $0.date == $1.date ? $0.id < $1.id : $0.date > $1.date }
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 4) {
        let groups = Dictionary(grouping: merged) { Calendar.current.startOfDay(for: $0.date) }
        ForEach(groups.keys.sorted(by: >), id: \.self) { day in
          VStack(alignment: .leading, spacing: 2) {
            Text(NativeImmichClient.formatChineseDate(day)).font(.headline).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
            let gridSpacing: CGFloat = columns > 7 ? 1 : 2
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: columns), spacing: gridSpacing) {
              ForEach(groups[day] ?? []) { entry in
                ZStack(alignment: .topTrailing) {
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
                        .preference(key: NativeItemFramePreferenceKey.self, value: [entry.id: geo.frame(in: .named("resultGridScrollSpace"))])
                      }
                    )
                    .clipped()
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
                        Image(systemName: entry.cloudSymbol())
                          .font(.system(size: columns > 4 ? 7 : 13, weight: .semibold))
                          .foregroundColor(.white).shadow(color: .black, radius: 2)
                          .padding(columns > 4 ? 1.5 : 3)
                      }
                    }

                  if isSelecting {
                    ZStack {
                      Circle()
                        .fill(selectedIDs.contains(entry.id) ? Color.blue : Color.black.opacity(0.35))
                        .frame(width: 22, height: 22)
                      if selectedIDs.contains(entry.id) {
                        Image(systemName: "checkmark")
                          .font(.system(size: 11, weight: .bold))
                          .foregroundColor(.white)
                      } else {
                        Circle()
                          .stroke(Color.white, lineWidth: 1.5)
                          .frame(width: 20, height: 20)
                      }
                    }
                    .padding(columns > 4 ? 2 : 4)
                  }
                }
                .contentShape(Rectangle())
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
        if hasOlder && !assets.isEmpty {
          ProgressView().frame(maxWidth: .infinity).padding(16)
            .onAppear { loadMore() }
        }
      }
    }
    .coordinateSpace(name: "resultGridScrollSpace")
    .nativeScrollDisabled(isDragSelecting)
    .onPreferenceChange(NativeItemFramePreferenceKey.self) { frames in
      itemBounds = frames
    }
    .simultaneousGesture(
      LongPressGesture(minimumDuration: 0.28, maximumDistance: 15)
        .sequenced(before: DragGesture(coordinateSpace: .named("resultGridScrollSpace")))
        .onChanged { value in
          guard !isMagnifying else { return }
          switch value {
          case .first:
            break
          case .second(true, let drag):
            if !isDragSelecting {
              isDragSelecting = true
              let loc = drag?.startLocation ?? drag?.location
              if let loc = loc,
                 let hitID = itemBounds.first(where: { $0.value.contains(loc) })?.key {
                if !isSelecting {
                  enterSelection(startingWith: hitID, at: loc)
                } else {
                  startDragSelectionInSelectMode(startingWith: hitID, at: loc)
                }
              }
            }
            if let drag = drag {
              handle2DDragSelection(at: drag.location)
            }
          default:
            break
          }
        }
        .onEnded { _ in
          isDragSelecting = false
          finishDragSelection()
        }
    )
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
    .fullScreenCover(item: $activeViewerItem) { item in
      NativeUnifiedGalleryViewer(
        client: client,
        device: NativeDeviceLibrary(),
        items: merged,
        initialItem: item
      )
    }
  }

  private func enterSelection(startingWith id: String, at location: CGPoint? = nil) {
    guard !isSelecting else { return }
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    setIsSelecting(true)
    dragStartAssetID = id
    let startLoc = location ?? itemBounds[id].map { CGPoint(x: $0.midX, y: $0.midY) }
    dragStartLocation = startLoc
    dragInitialSelectedIDs = selectedIDs
    let alreadySelected = selectedIDs.contains(id)
    dragSelectMode = !alreadySelected
    var updated = selectedIDs
    if dragSelectMode {
      updated.insert(id)
    } else {
      updated.remove(id)
    }
    setSelectedIDs(updated)
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
    var updated = selectedIDs
    if dragSelectMode {
      updated.insert(id)
    } else {
      updated.remove(id)
    }
    setSelectedIDs(updated)
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
      setSelectedIDs(updated)
    }
  }

  private func finishDragSelection() {
    dragStartLocation = nil
    dragStartAssetID = nil
    dragInitialSelectedIDs.removeAll()
  }

  private func toggleSelection(_ id: String) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    var updated = selectedIDs
    if updated.contains(id) {
      updated.remove(id)
    } else {
      updated.insert(id)
    }
    setSelectedIDs(updated)
  }
}

enum NativeAssetState {
  case local   // device only, not synced to server -> icloud.slash
  case remote  // server only, not on device -> cloud
  case merged  // synced on both server and device -> checkmark.icloud
}

struct NativeGridItem: Identifiable {
  let server: NativeAsset?
  let local: NativeDeviceAsset?

  var id: String {
    if let server, let local { return "merged:\(server.id):\(local.id)" }
    if let server { return "server:\(server.id)" }
    return "local:\(local?.id ?? "")"
  }

  var date: Date { server?.date ?? local?.date ?? .distantPast }

  var isVideo: Bool {
    if let server { return !server.isImage }
    if let local { return local.isVideo }
    return false
  }

  var state: NativeAssetState {
    if let local {
      if server != nil || NativeSyncCacheStore.shared.isMatched(localId: local.id) {
        return .merged
      } else {
        return .local
      }
    } else {
      return .remote
    }
  }

  func cloudSymbol(matchedServerIDs: [String: String] = NativeSyncCacheStore.shared.matchedServerIDs) -> String {
    if let local {
      if server != nil || matchedServerIDs[local.id] != nil {
        return "checkmark.icloud"
      } else {
        return "icloud.slash"
      }
    } else {
      return "cloud"
    }
  }
}

private struct NativeSearchView: View {
  let client: NativeImmichClient
  @StateObject private var model: NativeResultsModel
  @State private var term = ""
  @State private var submitted = ""
  @State private var smartMode = false
  @State private var explore: [NativeExploreSection] = []
  @State private var exploreError: String?
  @State private var filterPhotos = true
  @State private var filterVideos = true
  @State private var favoritesOnly = false
  @State private var after = Date()
  @State private var before = Date()
  @State private var useAfter = false
  @State private var useBefore = false
  init(client: NativeImmichClient) {
    self.client = client
    _model = StateObject(wrappedValue: NativeResultsModel(client))
  }
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        HStack {
          TextField(smartMode ? "描述你要找的照片" : "搜索文件名、路径或描述", text: $term)
            .textFieldStyle(.roundedBorder).submitLabel(.search)
            .onSubmit { runSearch() }
          if !term.isEmpty { Button { term = ""; runSearch() } label: { Image(systemName: "xmark.circle.fill") } }
        }.padding(.horizontal)
        HStack {
          Picker("搜索方式", selection: $smartMode) {
            Text("文件与信息").tag(false); Text("智能搜索").tag(true)
          }.pickerStyle(.segmented)
          Menu {
            Toggle("照片", isOn: $filterPhotos)
            Toggle("视频", isOn: $filterVideos)
            Toggle("只看收藏", isOn: $favoritesOnly)
            Toggle("开始日期", isOn: $useAfter)
            Toggle("结束日期", isOn: $useBefore)
          } label: { Image(systemName: "line.3.horizontal.decrease.circle").padding(8) }
        }.padding(.horizontal)
        if useAfter { DatePicker("从", selection: $after, displayedComponents: .date).padding(.horizontal) }
        if useBefore { DatePicker("至", selection: $before, displayedComponents: .date).padding(.horizontal) }
        if let error = model.error {
          HStack { Text(error).font(.caption); Button("重试") { runSearch() } }.padding(8)
        }
        if submitted.isEmpty && model.assets.isEmpty && !model.loading && !favoritesOnly && !useAfter && !useBefore && filterPhotos && filterVideos {
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              if let exploreError { Text(exploreError).font(.caption); Button("重试探索") { Task { await loadExplore() } } }
              ForEach(explore) { section in
                VStack(alignment: .leading) {
                  Text(section.id).font(.headline)
                  ScrollView(.horizontal) {
                    HStack {
                      ForEach(section.items) { tile in
                        Button { term = tile.name; runSearch() } label: {
                          VStack(alignment: .leading, spacing: 4) {
                            Color.clear
                              .frame(width: 108, height: 108)
                              .overlay(
                                GeometryReader { geo in
                                  Group {
                                    if let asset = tile.asset {
                                      NativeThumbnail(client: client, asset: asset)
                                    } else {
                                      Rectangle().fill(Color(uiColor: .secondarySystemBackground))
                                        .overlay {
                                          Image(systemName: "photo")
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                  }
                                  .frame(width: geo.size.width, height: geo.size.height)
                                  .clipped()
                                }
                              )
                              .clipped()
                            Text(tile.name).font(.caption).lineLimit(1)
                          }.frame(width: 108)
                        }.buttonStyle(.plain)
                      }
                    }
                  }
                }
              }
              Text("本机尚未上传的照片不参与服务器语义搜索").font(.caption).foregroundColor(.secondary)
            }.padding()
          }
        } else if model.assets.isEmpty && !model.loading {
          Spacer(); Text("没有找到匹配的服务器照片").foregroundColor(.secondary); Spacer()
        } else {
          NativeResultGrid(client: client, assets: model.assets, hasOlder: model.next != nil) {
            Task { await fetch(reset: false) }
          }
        }
        if model.loading { ProgressView().padding(8) }
      }
      .navigationTitle("搜索")
      .task { await loadExplore() }
      .onChange(of: smartMode) { _ in runSearch() }
      .onChange(of: filterPhotos) { _ in runSearch() }
      .onChange(of: filterVideos) { _ in runSearch() }
      .onChange(of: favoritesOnly) { _ in runSearch() }
      .onChange(of: useAfter) { _ in runSearch() }
      .onChange(of: useBefore) { _ in runSearch() }
      .onChange(of: after) { _ in if useAfter { runSearch() } }
      .onChange(of: before) { _ in if useBefore { runSearch() } }
    }.navigationViewStyle(.stack)
  }

  private var filters: [String: Any] {
    var value: [String: Any] = [:]
    if filterPhotos != filterVideos { value["type"] = ["eq": filterPhotos ? "IMAGE" : "VIDEO"] }
    if favoritesOnly { value["isFavorite"] = ["eq": true] }
    let formatter = ISO8601DateFormatter()
    if useAfter { value["takenAt"] = ["gte": formatter.string(from: after)] }
    if useBefore {
      var bounds = value["takenAt"] as? [String: String] ?? [:]
      bounds["lte"] = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: before) ?? before)
      value["takenAt"] = bounds
    }
    return value
  }

  private func runSearch() {
    submitted = term.trimmingCharacters(in: .whitespacesAndNewlines)
    Task { await fetch(reset: true) }
  }

  private func fetch(reset: Bool) async {
    guard filterPhotos || filterVideos else {
      if reset { model.clear() }
      return
    }
    if smartMode && !submitted.isEmpty { await model.smart(query: submitted, filter: filters, reset: reset) }
    else { await model.load(query: submitted.isEmpty ? nil : submitted, filter: filters, reset: reset) }
  }

  private func loadExplore() async {
    guard explore.isEmpty else { return }
    do { explore = try await client.explore(); exploreError = nil }
    catch { exploreError = error.localizedDescription }
  }
}

enum NativeAlbumOrigin {
  case merged
  case server
  case local
}

private struct NativeAlbumEntry: Identifiable, Equatable {
  let id: String
  let title: String
  let server: NativeServerAlbum?
  let device: NativeDeviceAlbum?
  let origin: NativeAlbumOrigin

  static func == (lhs: NativeAlbumEntry, rhs: NativeAlbumEntry) -> Bool {
    lhs.id == rhs.id
  }

  var countDescription: String {
    switch origin {
    case .merged:
      let s = server?.count ?? 0
      let d = device?.count ?? 0
      return "云端 \(s) · 本地 \(d)"
    case .server:
      return "\(server?.count ?? 0) 项"
    case .local:
      return "\(device?.count ?? 0) 项"
    }
  }
}

private struct NativeAlbumCoverView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  let entry: NativeAlbumEntry
  let mergeAlbums: Bool

  var body: some View {
    Color.clear
      .aspectRatio(1, contentMode: .fit)
      .overlay(
        Group {
          if let thumbId = entry.server?.thumbnailAssetId {
            NativeThumbnail(
              client: client,
              asset: NativeAsset(id: thumbId, date: .distantPast, isImage: true, isFavorite: false, thumbhash: nil),
              columns: 2
            )
          } else if let devAlbum = entry.device, let firstLocal = device.firstAsset(in: devAlbum) {
            NativeDeviceThumbnail(asset: firstLocal, columns: 2)
          } else {
            ZStack {
              Color(uiColor: .secondarySystemBackground)
              Image(systemName: "photo.on.rectangle")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            }
          }
        }
      )
      .clipped()
      .cornerRadius(10)
      .overlay(alignment: .bottomTrailing) {
        if !mergeAlbums {
          Image(systemName: entry.origin == .server ? "cloud.fill" : "iphone")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(5)
            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
            .padding(6)
        }
      }
  }
}

private struct NativeAlbumCard: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  let entry: NativeAlbumEntry
  let mergeAlbums: Bool
  let isSelecting: Bool
  let isSelected: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      ZStack(alignment: .topTrailing) {
        NativeAlbumCoverView(client: client, device: device, entry: entry, mergeAlbums: mergeAlbums)
        if isSelecting {
          ZStack {
            Circle()
              .fill(isSelected ? Color.blue : Color.black.opacity(0.35))
              .frame(width: 24, height: 24)
            if isSelected {
              Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            } else {
              Circle()
                .stroke(Color.white, lineWidth: 1.5)
                .frame(width: 22, height: 22)
            }
          }
          .padding(8)
        }
      }
      VStack(alignment: .leading, spacing: 2) {
        Text(entry.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)
          .lineLimit(1)
        Text(entry.countDescription)
          .font(.caption2)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

private struct NativeAlbumsView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  @AppStorage("immichz_merge_albums") private var mergeAlbums = true
  @State private var serverAlbums: [NativeServerAlbum] = []
  @State private var error: String?
  @State private var loaded = false
  @State private var isLoading = false

  @State private var isSelecting = false
  @State private var isDragSelecting = false
  @State private var selectedAlbumIDs: Set<String> = []
  @State private var itemBounds: [String: CGRect] = [:]
  @State private var dragStartLocation: CGPoint? = nil
  @State private var dragStartAlbumID: String? = nil
  @State private var dragInitialSelectedIDs: Set<String> = []
  @State private var dragSelectMode: Bool = true
  @State private var activeEntry: NativeAlbumEntry? = nil

  private let gridColumns = [
    GridItem(.flexible(), spacing: 14),
    GridItem(.flexible(), spacing: 14)
  ]

  private var entries: [NativeAlbumEntry] {
    if mergeAlbums {
      let serverGroups = Dictionary(grouping: serverAlbums) { $0.name.trimmingCharacters(in: .whitespaces).folding(options: .caseInsensitive, locale: .current) }
      let localGroups = Dictionary(grouping: device.albums) { $0.name.trimmingCharacters(in: .whitespaces).folding(options: .caseInsensitive, locale: .current) }
      let combined = Set(serverGroups.keys).union(localGroups.keys)
      return combined.sorted().flatMap { key -> [NativeAlbumEntry] in
        let remote = serverGroups[key] ?? []
        let local = localGroups[key] ?? []
        if remote.count == 1 && local.count == 1 {
          return [NativeAlbumEntry(id: "pair:\(remote[0].id):\(local[0].id)", title: remote[0].name, server: remote[0], device: local[0], origin: .merged)]
        }
        return remote.map { NativeAlbumEntry(id: "server:\($0.id)", title: $0.name, server: $0, device: nil, origin: .server) }
          + local.map { NativeAlbumEntry(id: "local:\($0.id)", title: $0.name, server: nil, device: $0, origin: .local) }
      }
    } else {
      var result: [NativeAlbumEntry] = []
      for s in serverAlbums {
        result.append(NativeAlbumEntry(id: "server:\(s.id)", title: s.name, server: s, device: nil, origin: .server))
      }
      for d in device.albums {
        result.append(NativeAlbumEntry(id: "local:\(d.id)", title: d.name, server: nil, device: d, origin: .local))
      }
      return result
    }
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          if let active = activeEntry {
            NavigationLink(
              destination: NativeAlbumDetail(client: client, device: device, entry: active, mergeAlbums: mergeAlbums),
              isActive: Binding(
                get: { activeEntry != nil },
                set: { if !$0 { activeEntry = nil } }
              )
            ) {
              EmptyView()
            }
            .hidden()
          }

          if !device.authorized {
            Button("允许访问设备相册（可选）") { Task { await device.requestAccess() } }
              .font(.footnote)
              .padding(.horizontal)
          }
          if let error {
            HStack {
              Text(error).font(.caption).foregroundColor(.red)
              Button("重试") { Task { await reload() } }.font(.caption)
            }
            .padding(.horizontal)
          }

          LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(entries) { entry in
              NativeAlbumCard(
                client: client,
                device: device,
                entry: entry,
                mergeAlbums: mergeAlbums,
                isSelecting: isSelecting,
                isSelected: selectedAlbumIDs.contains(entry.id)
              )
              .background(
                GeometryReader { geo in
                  Color.clear
                    .preference(key: NativeItemFramePreferenceKey.self, value: [entry.id: geo.frame(in: .named("albumsScrollSpace"))])
                }
              )
              .contentShape(Rectangle())
              .onTapGesture {
                if isSelecting {
                  toggleAlbumSelection(entry.id)
                } else {
                  activeEntry = entry
                }
              }
              .onLongPressGesture(minimumDuration: 0.28, maximumDistance: 15) {
                if !isSelecting {
                  enterAlbumSelection(startingWith: entry.id)
                } else {
                  startDragSelectionInAlbumMode(startingWith: entry.id)
                }
              }
              .id(entry.id)
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          .padding(.bottom, 24)
        }
      }
      .coordinateSpace(name: "albumsScrollSpace")
      .nativeScrollDisabled(isDragSelecting)
      .onPreferenceChange(NativeItemFramePreferenceKey.self) { frames in
        itemBounds = frames
      }
      .simultaneousGesture(
        LongPressGesture(minimumDuration: 0.28, maximumDistance: 15)
          .sequenced(before: DragGesture(coordinateSpace: .named("albumsScrollSpace")))
          .onChanged { value in
            switch value {
            case .first:
              break
            case .second(true, let drag):
              if !isDragSelecting {
                isDragSelecting = true
                let loc = drag?.startLocation ?? drag?.location
                if let loc = loc,
                   let hitID = itemBounds.first(where: { $0.value.contains(loc) })?.key {
                  if !isSelecting {
                    enterAlbumSelection(startingWith: hitID, at: loc)
                  } else {
                    startDragSelectionInAlbumMode(startingWith: hitID, at: loc)
                  }
                }
              }
              if let drag = drag {
                handle2DDragSelection(at: drag.location)
              }
            default:
              break
            }
          }
          .onEnded { _ in
            isDragSelecting = false
            finishDragSelection()
          }
      )
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          if isSelecting {
            Button("取消") {
              isSelecting = false
              selectedAlbumIDs.removeAll()
            }
          } else {
            HStack(spacing: 6) {
              Text("\(entries.count) 个相册").font(.caption).foregroundColor(.secondary)
              if isLoading {
                ProgressView()
                  .scaleEffect(0.7)
              }
            }
          }
        }
        ToolbarItem(placement: .principal) {
          if isSelecting {
            Text("已选 \(selectedAlbumIDs.count) 个相册").font(.headline)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          if isSelecting {
            Button("全选") {
              selectedAlbumIDs = Set(entries.map(\.id))
            }
          } else {
            Button {
              Task {
                await reload()
                device.refresh()
              }
            } label: {
              Image(systemName: "arrow.clockwise")
            }
          }
        }
      }
      .refreshable { await reload(); device.refresh() }
      .task { if !loaded { loaded = true; await reload() } }
    }
    .navigationViewStyle(.stack)
  }

  private func reload() async {
    isLoading = true
    defer { isLoading = false }
    do { serverAlbums = try await client.serverAlbums(); error = nil }
    catch { self.error = error.localizedDescription }
  }

  private func enterAlbumSelection(startingWith id: String, at location: CGPoint? = nil) {
    guard !isSelecting else { return }
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    isSelecting = true
    dragStartAlbumID = id
    let startLoc = location ?? itemBounds[id].map { CGPoint(x: $0.midX, y: $0.midY) }
    dragStartLocation = startLoc
    dragInitialSelectedIDs = selectedAlbumIDs
    let alreadySelected = selectedAlbumIDs.contains(id)
    dragSelectMode = !alreadySelected
    if dragSelectMode {
      selectedAlbumIDs.insert(id)
    } else {
      selectedAlbumIDs.remove(id)
    }
  }

  private func startDragSelectionInAlbumMode(startingWith id: String, at location: CGPoint? = nil) {
    guard dragStartAlbumID != id || dragStartLocation == nil else { return }
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    dragStartAlbumID = id
    let startLoc = location ?? itemBounds[id].map { CGPoint(x: $0.midX, y: $0.midY) }
    dragStartLocation = startLoc
    dragInitialSelectedIDs = selectedAlbumIDs
    let alreadySelected = selectedAlbumIDs.contains(id)
    dragSelectMode = !alreadySelected
    if dragSelectMode {
      selectedAlbumIDs.insert(id)
    } else {
      selectedAlbumIDs.remove(id)
    }
  }

  private func handle2DDragSelection(at location: CGPoint) {
    guard isSelecting else { return }
    if dragStartLocation == nil {
      dragStartLocation = location
      dragInitialSelectedIDs = selectedAlbumIDs
      if let hitID = itemBounds.first(where: { $0.value.contains(location) })?.key {
        dragStartAlbumID = hitID
        dragSelectMode = !selectedAlbumIDs.contains(hitID)
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
    if let startID = dragStartAlbumID {
      itemsInRect.insert(startID)
    }

    var updated = dragInitialSelectedIDs
    if dragSelectMode {
      updated.formUnion(itemsInRect)
    } else {
      updated.subtract(itemsInRect)
    }

    if updated != selectedAlbumIDs {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      selectedAlbumIDs = updated
    }
  }

  private func finishDragSelection() {
    dragStartLocation = nil
    dragStartAlbumID = nil
    dragInitialSelectedIDs.removeAll()
  }

  private func toggleAlbumSelection(_ id: String) {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    if selectedAlbumIDs.contains(id) {
      selectedAlbumIDs.remove(id)
    } else {
      selectedAlbumIDs.insert(id)
    }
  }
}

private struct NativeAlbumDetail: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  let entry: NativeAlbumEntry
  let mergeAlbums: Bool
  @StateObject private var model: NativeResultsModel

  @State private var isSelecting = false
  @State private var selectedIDs: Set<String> = []

  init(client: NativeImmichClient, device: NativeDeviceLibrary, entry: NativeAlbumEntry, mergeAlbums: Bool) {
    self.client = client
    self.device = device
    self.entry = entry
    self.mergeAlbums = mergeAlbums
    _model = StateObject(wrappedValue: NativeResultsModel(client))
  }

  private var localAssetsToDisplay: [NativeDeviceAsset] {
    if mergeAlbums {
      return entry.device.map { device.assets(in: $0) } ?? []
    } else {
      return entry.origin == .local ? (entry.device.map { device.assets(in: $0) } ?? []) : []
    }
  }

  private var serverAssetsToDisplay: [NativeAsset] {
    if mergeAlbums {
      return model.assets
    } else {
      return entry.origin == .server ? model.assets : []
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      if let error = model.error {
        HStack {
          Text(error).font(.caption).foregroundColor(.red)
          Button("重试") { Task { await model.load(albumId: entry.server?.id, reset: model.assets.isEmpty) } }
            .font(.caption)
        }
        .padding(6)
      }
      NativeResultGrid(
        client: client,
        assets: serverAssetsToDisplay,
        localAssets: localAssetsToDisplay,
        hasOlder: entry.server != nil && model.next != nil,
        isSelecting: $isSelecting,
        selectedIDs: $selectedIDs
      ) {
        if let id = entry.server?.id { Task { await model.load(albumId: id) } }
      }
      if model.loading { ProgressView().padding(8) }
    }
    .navigationTitle(isSelecting ? "" : entry.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if isSelecting {
          Button("取消") {
            isSelecting = false
            selectedIDs.removeAll()
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
            let matched = NativeSyncCacheStore.shared.matchedServerIDs
            let serverById = Dictionary(serverAssetsToDisplay.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            var usedServerIDs = Set<String>()
            var ids: [String] = []
            for local in localAssetsToDisplay {
              if let sID = matched[local.id], let sAsset = serverById[sID] {
                ids.append("merged:\(sAsset.id):\(local.id)")
                usedServerIDs.insert(sAsset.id)
              } else {
                ids.append("local:\(local.id)")
              }
            }
            for server in serverAssetsToDisplay {
              if !usedServerIDs.contains(server.id) {
                ids.append("server:\(server.id)")
              }
            }
            selectedIDs = Set(ids)
          }
        } else {
          Button("选择") {
            isSelecting = true
          }
        }
      }
    }
    .task {
      if let server = entry.server {
        await model.load(albumId: server.id, reset: true)
      }
    }
  }
}

private struct NativeLibraryView: View {
  let client: NativeImmichClient
  @ObservedObject var device: NativeDeviceLibrary
  @AppStorage("immichz_merge_albums") private var mergeAlbums = true
  @State private var features: [String: Any] = [:]
  private var buildCommit: String {
    guard let value = Bundle.main.object(forInfoDictionaryKey: "ImmichZGitCommit") as? String,
          !value.isEmpty,
          value != "$(IMMICHZ_GIT_COMMIT)" else { return "unknown" }
    return value
  }

  private var appVersion: String {
    let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.1"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    return buildNumber.isEmpty ? shortVersion : "\(shortVersion)+\(buildNumber)"
  }

  var body: some View {
    NavigationView {
      List {
        Section("相册偏好") {
          Toggle("合并本地和远端相册", isOn: $mergeAlbums)
        }
        Section("快捷入口") {
          NavigationLink("收藏") { NativeFilteredView(client: client, title: "收藏", filter: ["isFavorite": ["eq": true]]) }
          NavigationLink("归档") { NativeFilteredView(client: client, title: "归档", filter: ["visibility": ["eq": "archive"]]) }
          NavigationLink("共享链接") {
            NativeLibrarySection(client: client, title: "共享链接", path: "shared-links", query: []) { row in
              guard let id = row["id"] as? String else { return nil }
              return LibraryRow(id: id, title: row["description"] as? String ?? row["slug"] as? String ?? "共享链接", detail: row["type"] as? String ?? "", assetID: nil)
            }
          }
          if features["trash"] as? Bool == true {
            NavigationLink("回收站") { NativeFilteredView(client: client, title: "回收站", filter: ["trashedAt": ["ne": NSNull()]]) }
          }
        }
        Section("集合") {
          if features["facialRecognition"] as? Bool != false { NavigationLink("人物") { NativePeopleView(client: client) } }
          if features["map"] as? Bool != false { NavigationLink("地点") { NativePlacesView(client: client) } }
          NavigationLink("本机") {
            if device.authorized { NativeDeviceGrid(title: "本机照片", assets: device.assets) }
            else { Button("允许访问设备相册") { Task { await device.requestAccess() } } }
          }
          NavigationLink("回忆") {
            NativeLibrarySection(client: client, title: "回忆", path: "memories", query: []) { row in
              guard let id = row["id"] as? String else { return nil }
              return LibraryRow(id: id, title: row["type"] as? String ?? "回忆", detail: row["memoryAt"] as? String ?? "", assetID: nil)
            }
          }
        }
        Section("快捷访问") {
          NavigationLink("服务器文件夹") { NativeFoldersView(client: client) }
          NavigationLink("锁定文件夹 · 使用完整应用") { NativeFallbackNote() }
          NavigationLink("伙伴共享") {
            NativeLibrarySection(client: client, title: "伙伴共享", path: "partners", query: [URLQueryItem(name: "direction", value: "shared-by")]) { row in
              guard let id = row["id"] as? String else { return nil }
              return LibraryRow(id: id, title: row["name"] as? String ?? row["email"] as? String ?? "伙伴", detail: row["email"] as? String ?? "", assetID: nil)
            }
          }
          NavigationLink("标签") {
            NativeLibrarySection(client: client, title: "标签", path: "tags", query: []) { row in
              guard let id = row["id"] as? String else { return nil }
              return LibraryRow(id: id, title: row["value"] as? String ?? row["name"] as? String ?? "标签", detail: "", assetID: id)
            }
          }
        }
        Section {
          HStack {
            Spacer()
            Text("build \(buildCommit)  \(appVersion)")
              .font(.footnote.monospaced())
              .foregroundColor(.secondary)
            Spacer()
          }
          .listRowBackground(Color.clear)
        }
      }
      .navigationTitle("设置")
      .task {
        do { features = try await client.send(path: "server/features") }
        catch { features = [:] }
      }
    }.navigationViewStyle(.stack)
  }
}

private struct NativeFallbackNote: View {
  var body: some View { Text("此功能暂未提供。").padding() }
}

struct NativeFilteredView: View {
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

final class TabBarFinderView: UIView {
  var onSetup: ((UIView) -> Void)?

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window != nil {
      onSetup?(self)
    }
  }
}

private struct TabBarDoubleTapHelper: UIViewRepresentable {
  let onPhotosDoubleTap: () -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onPhotosDoubleTap: onPhotosDoubleTap)
  }

  func makeUIView(context: Context) -> TabBarFinderView {
    let view = TabBarFinderView()
    view.backgroundColor = .clear
    view.isUserInteractionEnabled = false
    view.onSetup = { [weak coordinator = context.coordinator] v in
      coordinator?.setup(from: v)
    }
    DispatchQueue.main.async {
      context.coordinator.setup(from: view)
    }
    return view
  }

  func updateUIView(_ uiView: TabBarFinderView, context: Context) {
    context.coordinator.onPhotosDoubleTap = onPhotosDoubleTap
    context.coordinator.setup(from: uiView)
  }

  final class Coordinator: NSObject, UIGestureRecognizerDelegate {
    var onPhotosDoubleTap: () -> Void
    private weak var tabBar: UITabBar?
    private var doubleTapGesture: UITapGestureRecognizer?

    init(onPhotosDoubleTap: @escaping () -> Void) {
      self.onPhotosDoubleTap = onPhotosDoubleTap
    }

    func setup(from view: UIView) {
      guard let tabBar = findTabBar(from: view) else { return }
      if self.tabBar === tabBar { return }
      if let existing = doubleTapGesture, let oldBar = self.tabBar {
        oldBar.removeGestureRecognizer(existing)
      }
      self.tabBar = tabBar

      let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
      doubleTap.numberOfTapsRequired = 2
      doubleTap.cancelsTouchesInView = false
      doubleTap.delaysTouchesEnded = false
      doubleTap.delegate = self
      tabBar.addGestureRecognizer(doubleTap)
      self.doubleTapGesture = doubleTap
    }

    private func findTabBar(from view: UIView) -> UITabBar? {
      var responder: UIResponder? = view
      while let r = responder {
        if let tc = r as? UITabBarController { return tc.tabBar }
        if let vc = r as? UIViewController, let tc = vc.tabBarController { return tc.tabBar }
        responder = r.next
      }
      if let window = view.window ?? UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
        .first {
        return findTabBarIn(view: window)
      }
      return nil
    }

    private func findTabBarIn(view: UIView) -> UITabBar? {
      if let bar = view as? UITabBar { return bar }
      for sub in view.subviews {
        if let bar = findTabBarIn(view: sub) { return bar }
      }
      return nil
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
      guard let tabBar = self.tabBar ?? gesture.view as? UITabBar else { return }
      let location = gesture.location(in: tabBar)
      let width = tabBar.bounds.width
      guard width > 0 else { return }
      let tabWidth = width / 4.0
      if location.x >= 0 && location.x <= tabWidth && location.y >= 0 && location.y <= tabBar.bounds.height {
        onPhotosDoubleTap()
      }
    }

    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      true
    }
  }
}

struct NativeTabShell: View {
  let client: NativeImmichClient
  let onUseFlutter: () -> Void
  let onLogout: () -> Void
  @StateObject private var device = NativeDeviceLibrary()
  @State private var selectedTab = 0
  @State private var lastTab0Tap: Date = .distantPast

  var body: some View {
    let tabBinding = Binding<Int>(
      get: { selectedTab },
      set: { newTab in
        if newTab == 0 {
          let now = Date()
          if now.timeIntervalSince(lastTab0Tap) < 0.55 {
            NotificationCenter.default.post(name: .immichScrollPhotosToBottom, object: nil)
          }
          lastTab0Tap = now
        }
        selectedTab = newTab
      }
    )

    TabView(selection: tabBinding) {
      NativePhotosView(client: client, device: device, onUseFlutter: onUseFlutter, onLogout: onLogout)
        .tabItem { Label("照片", systemImage: "photo.on.rectangle") }
        .tag(0)
      NativeSearchView(client: client)
        .tabItem { Label("搜索", systemImage: "magnifyingglass") }
        .tag(1)
      NativeAlbumsView(client: client, device: device)
        .tabItem { Label("相册", systemImage: "rectangle.stack") }
        .tag(2)
      NativeLibraryView(client: client, device: device)
        .tabItem { Label("设置", systemImage: "gearshape") }
        .tag(3)
    }
    .background(
      TabBarDoubleTapHelper {
        selectedTab = 0
        NotificationCenter.default.post(name: .immichScrollPhotosToBottom, object: nil)
      }
    )
  }
}

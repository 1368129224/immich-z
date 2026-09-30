import Foundation
import MapKit
import Photos
import SwiftUI

struct LibraryRow: Identifiable {
  let id: String
  let title: String
  let detail: String
  let assetID: String?
}

extension NativeImmichClient {
  func libraryRows(_ path: String, query: [URLQueryItem] = []) async throws -> [[String: Any]] {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard var components = URLComponents(string: base + "/" + path) else { throw NativeLibraryError.invalidResponse }
    components.queryItems = query.isEmpty ? nil : query
    guard let url = components.url else { throw NativeLibraryError.invalidResponse }
    var request = URLRequest(url: url)
    if let token = config.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
    if let key = config.apiKey { request.setValue(key, forHTTPHeaderField: "x-api-key") }
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
          let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { throw NativeLibraryError.invalidResponse }
    return rows
  }
}

private enum NativeLibraryError: LocalizedError {
  case invalidResponse
  var errorDescription: String? { "服务器暂时无法提供该集合。" }
}

struct NativeLibrarySection: View {
  let client: NativeImmichClient
  let title: String
  let path: String
  let query: [URLQueryItem]
  let transform: ([String: Any]) -> LibraryRow?
  @State private var rows: [LibraryRow] = []
  @State private var error: String?
  @State private var loading = false

  var body: some View {
    List {
      if loading { ProgressView() }
      if let error { Text(error).foregroundColor(.red); Button("重试") { Task { await reload() } } }
      if !loading && error == nil && rows.isEmpty { Text("暂无内容").foregroundColor(.secondary) }
      ForEach(rows) { row in
        if let tag = row.assetID {
          NavigationLink {
            NativeFilteredView(client: client, title: row.title, filter: ["tagIds": ["any": [tag]]])
          } label: { rowLabel(row) }
        } else { rowLabel(row) }
      }
    }
    .navigationTitle(title)
    .refreshable { await reload() }
    .task { await reload() }
  }

  private func rowLabel(_ row: LibraryRow) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(row.title)
      if !row.detail.isEmpty { Text(row.detail).font(.caption).foregroundColor(.secondary) }
    }
  }

  private func reload() async {
    guard !loading else { return }
    loading = true
    defer { loading = false }
    do { let response = try await client.libraryRows(path, query: query); rows = response.compactMap(transform); error = nil }
    catch { self.error = error.localizedDescription }
  }
}

struct NativePeopleView: View {
  let client: NativeImmichClient
  @State private var people: [[String: Any]] = []
  @State private var page = 1
  @State private var hasMore = true
  @State private var loading = false
  @State private var error: String?

  var body: some View {
    List {
      if let error { Text(error).foregroundColor(.red); Button("重试") { Task { await load() } } }
      if !loading && people.isEmpty && error == nil { Text("暂无人物").foregroundColor(.secondary) }
      ForEach(people.indices, id: \.self) { index in
        if let id = people[index]["id"] as? String {
          NavigationLink((people[index]["name"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "未命名") {
            NativeFilteredView(client: client, title: people[index]["name"] as? String ?? "人物", filter: ["personIds": ["any": [id]]])
          }
        }
      }
      if hasMore {
        Button(loading ? "加载中…" : "加载更多") { Task { await load() } }.disabled(loading)
      }
    }
    .navigationTitle("人物")
    .task { if people.isEmpty { await load() } }
  }

  private func load() async {
    guard !loading && hasMore else { return }
    loading = true
    defer { loading = false }
    do {
      let response = try await client.send(path: "people", query: [URLQueryItem(name: "page", value: String(page)), URLQueryItem(name: "size", value: "100")])
      guard let rows = response["people"] as? [[String: Any]] else { throw NativeLibraryError.invalidResponse }
      people += rows
      hasMore = response["hasNextPage"] as? Bool ?? false
      page += 1
      error = nil
    } catch { self.error = error.localizedDescription }
  }
}

struct NativePlacesView: View {
  let client: NativeImmichClient
  @State private var places: [String: Int] = [:]
  @State private var markers: [NativeMapPin] = []
  @State private var error: String?
  @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 150))

  var body: some View {
    VStack(spacing: 0) {
      Map(coordinateRegion: $region, annotationItems: markers) { pin in
        MapMarker(coordinate: pin.coordinate)
      }.frame(height: 240)
      List {
        if let error { Text(error).foregroundColor(.red); Button("重试") { Task { await load() } } }
        if places.isEmpty && error == nil { Text("暂无带位置的资产").foregroundColor(.secondary) }
        ForEach(places.keys.sorted(), id: \.self) { place in
          Text("\(place) · \(places[place] ?? 0)")
        }
      }
    }
    .navigationTitle("地点")
    .task { await load() }
  }

  private func load() async {
    do {
      let rows = try await client.libraryRows("map/markers")
      var totals: [String: Int] = [:]
      markers = rows.compactMap { row in
        let place = [row["city"], row["state"], row["country"]].compactMap { $0 as? String }.first(where: { !$0.isEmpty }) ?? "未知地点"
        totals[place, default: 0] += 1
        guard let lat = row["lat"] as? Double, let lon = row["lon"] as? Double,
              (-90...90).contains(lat), (-180...180).contains(lon), let id = row["id"] as? String else { return nil }
        return NativeMapPin(id: id, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
      }
      places = totals
      if let first = markers.first { region.center = first.coordinate; region.span = MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20) }
      error = nil
    } catch { self.error = error.localizedDescription }
  }
}

private struct NativeMapPin: Identifiable {
  let id: String
  let coordinate: CLLocationCoordinate2D
}

struct NativeFoldersView: View {
  let client: NativeImmichClient
  @State private var paths: [String] = []
  @State private var error: String?
  var body: some View {
    List {
      if let error { Text(error).foregroundColor(.red) }
      if paths.isEmpty && error == nil { Text("暂无服务器文件夹").foregroundColor(.secondary) }
      ForEach(paths, id: \.self) { path in
        NavigationLink(path) { NativeFolderAssets(client: client, path: path) }
      }
    }
    .navigationTitle("服务器文件夹")
    .task {
      do { paths = try await client.libraryStrings("view/folder/unique-paths"); error = nil }
      catch { self.error = error.localizedDescription }
    }
  }
}

private struct NativeFolderAssets: View {
  let client: NativeImmichClient
  let path: String
  @State private var assets: [NativeAsset] = []
  @State private var error: String?
  var body: some View {
    VStack {
      if let error { Text(error).foregroundColor(.red) }
      NativeResultGrid(client: client, assets: assets, hasOlder: false, loadMore: {})
    }
    .navigationTitle((path as NSString).lastPathComponent)
    .task {
      do {
        let rows = try await client.libraryRows("view/folder", query: [URLQueryItem(name: "path", value: path)])
        assets = rows.compactMap { row in
          guard let id = row["id"] as? String else { return nil }
          let text = row["fileCreatedAt"] as? String ?? ""
          return NativeAsset(id: id, date: ISO8601DateFormatter().date(from: text) ?? .distantPast, isImage: row["type"] as? String != "VIDEO", isFavorite: row["isFavorite"] as? Bool ?? false, thumbhash: row["thumbhash"] as? String)
        }
        error = nil
      } catch { self.error = error.localizedDescription }
    }
  }
}

extension NativeImmichClient {
  func libraryStrings(_ path: String) async throws -> [String] {
    let base = config.apiEndpoint ?? (Self.normalize(config.serverUrl) + "/api")
    guard let url = URL(string: base + "/" + path) else { throw NativeLibraryError.invalidResponse }
    var request = URLRequest(url: url)
    if let token = config.accessToken { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
    if let key = config.apiKey { request.setValue(key, forHTTPHeaderField: "x-api-key") }
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
          let strings = try JSONSerialization.jsonObject(with: data) as? [String] else { throw NativeLibraryError.invalidResponse }
    return strings
  }
}

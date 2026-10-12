import Flutter
import Runner
import UIKit
import XCTest

final class RunnerTests: XCTestCase {
  func testPhotosSourceFilterUsesActualCopyAndVerifiedMatch() {
    XCTAssertTrue(nativePhotosSourceIncludes(.all, hasLocal: true, hasServer: false, hasVerifiedMatch: false))
    XCTAssertFalse(nativePhotosSourceIncludes(.server, hasLocal: true, hasServer: false, hasVerifiedMatch: false))
    XCTAssertTrue(nativePhotosSourceIncludes(.server, hasLocal: true, hasServer: false, hasVerifiedMatch: true))
    XCTAssertTrue(nativePhotosSourceIncludes(.device, hasLocal: true, hasServer: true, hasVerifiedMatch: true))
    XCTAssertTrue(nativePhotosSourceIncludes(.server, hasLocal: false, hasServer: true, hasVerifiedMatch: false))
  }

  func testInitialTimelineWaitsForBothSourcesBeforePositioningAll() {
    XCTAssertFalse(nativeInitialTimelineReady(source: .all, remoteLoaded: true, remoteLoading: false, localSnapshotLoaded: false, localLoading: false))
    XCTAssertFalse(nativeInitialTimelineReady(source: .all, remoteLoaded: false, remoteLoading: false, localSnapshotLoaded: true, localLoading: false))
    XCTAssertFalse(nativeInitialTimelineReady(source: .all, remoteLoaded: true, remoteLoading: false, localSnapshotLoaded: true, localLoading: true))
    XCTAssertTrue(nativeInitialTimelineReady(source: .all, remoteLoaded: true, remoteLoading: false, localSnapshotLoaded: true, localLoading: false))
    XCTAssertTrue(nativeInitialTimelineReady(source: .device, remoteLoaded: false, remoteLoading: true, localSnapshotLoaded: true, localLoading: false))
    XCTAssertTrue(nativeInitialTimelineReady(source: .server, remoteLoaded: true, remoteLoading: false, localSnapshotLoaded: false, localLoading: true))
  }

  func testViewerImageFitsViewportWithoutCropping() {
    let viewport = CGSize(width: 390, height: 844)
    XCTAssertEqual(nativeAspectFitImageSize(imageSize: CGSize(width: 4000, height: 3000), viewportSize: viewport), CGSize(width: 390, height: 292.5))
    XCTAssertEqual(nativeAspectFitImageSize(imageSize: CGSize(width: 3000, height: 4000), viewportSize: viewport), CGSize(width: 390, height: 520))
    XCTAssertEqual(nativeAspectFitImageSize(imageSize: CGSize(width: 1000, height: 4000), viewportSize: viewport), CGSize(width: 211, height: 844))
    XCTAssertEqual(nativeAspectFitImageSize(imageSize: .zero, viewportSize: viewport), .zero)
  }

  func testPhotosPinchCellSizeIsContinuousAndClamped() {
    XCTAssertEqual(nativeClampedPhotosCellSize(100, magnification: 1), 100, accuracy: 0.001)
    XCTAssertEqual(nativeClampedPhotosCellSize(100, magnification: 1.5), 150, accuracy: 0.001)
    XCTAssertEqual(nativeClampedPhotosCellSize(100, magnification: 0.5), 72, accuracy: 0.001)
    XCTAssertEqual(nativeClampedPhotosCellSize(300, magnification: 2), 320, accuracy: 0.001)
  }

  func testPhotoFramePreferencesIgnoreTinyScrollMovementButTrackMeaningfulChanges() {
    let original: [String: CGRect] = ["a": CGRect(x: 0, y: 0, width: 100, height: 100)]
    let tinyMovement: [String: CGRect] = ["a": CGRect(x: 1, y: 2, width: 100, height: 100)]
    let meaningfulMovement: [String: CGRect] = ["a": CGRect(x: 1, y: 15, width: 100, height: 100)]
    let changedSet: [String: CGRect] = ["b": CGRect(x: 0, y: 0, width: 100, height: 100)]

    XCTAssertFalse(nativeShouldRefreshPhotoFrames(previous: original, next: tinyMovement, force: false))
    XCTAssertTrue(nativeShouldRefreshPhotoFrames(previous: original, next: meaningfulMovement, force: false))
    XCTAssertTrue(nativeShouldRefreshPhotoFrames(previous: original, next: tinyMovement, force: true))
    XCTAssertTrue(nativeShouldRefreshPhotoFrames(previous: original, next: changedSet, force: false))
    XCTAssertEqual(nativePhotoFramePreference(id: "offscreen", frame: CGRect(x: 0, y: 1000, width: 100, height: 100), viewportHeight: 800), [:])
    XCTAssertEqual(nativePhotoFramePreference(id: "visible", frame: CGRect(x: 0, y: 10, width: 100, height: 100), viewportHeight: 800).count, 1)
  }

  func testPhotosSourcePredicateKeepsUnloadedVerifiedMatchInCloudFilter() {
    XCTAssertTrue(nativePhotosSourceIncludes(.server, hasLocal: true, hasServer: false, hasVerifiedMatch: true))
    XCTAssertFalse(nativePhotosSourceIncludes(.server, hasLocal: true, hasServer: false, hasVerifiedMatch: false))
  }

  func testPhotosMixedSelectionActionCounts() {
    let local = NativeDeviceAsset(id: "local", date: .distantPast, isVideo: false, contentVersion: 0)
    let server = NativeAsset(id: "server", date: .distantPast, isImage: true, isFavorite: false, thumbhash: nil)
    let items = [NativeGridItem(server: nil, local: local), NativeGridItem(server: server, local: nil), NativeGridItem(server: server, local: local)]
    let availability = nativePhotosSelectionActionAvailability(items)
    XCTAssertEqual(availability.server, 2)
    XCTAssertEqual(availability.local, 2)
    XCTAssertEqual(availability.merged, 1)
  }

  func testBulkOperationSummaryReportsSuccessFailureAndUnconfirmedIDs() {
    let summary = nativeBulkOperationSummary(
      requestedIDs: ["success", "failure", "missing"],
      responses: [
        ["id": "success", "success": true],
        ["id": "failure", "success": false, "errorMessage": "not in album"],
        ["id": "unrequested", "success": true]
      ]
    )
    XCTAssertEqual(summary, NativeBulkOperationSummary(succeeded: 1, failed: 1, unconfirmed: 1))
  }

  func testBulkOperationSummaryTreatsDuplicateOrMalformedResponsesAsUnconfirmed() {
    let summary = nativeBulkOperationSummary(
      requestedIDs: ["duplicate", "malformed", "missing"],
      responses: [
        ["id": "duplicate", "success": true],
        ["id": "duplicate", "success": true],
        ["id": "malformed", "success": "yes"]
      ]
    )
    XCTAssertEqual(summary, NativeBulkOperationSummary(succeeded: 0, failed: 0, unconfirmed: 3))
  }

  func testRefreshPreservesOldestLoadedBucketBoundary() {
    let old = (0..<40).map { NativeBucket(id: "bucket\($0)", count: 1) }
    let refreshed = [NativeBucket(id: "new", count: 1)] + old
    XCTAssertEqual(nativeRefreshedBucketBoundary(old: old, next: 25, refreshed: refreshed), 26)
    XCTAssertEqual(nativeRefreshedBucketBoundary(old: old, next: 40, refreshed: refreshed), 41)
    XCTAssertEqual(nativeRefreshedBucketBoundary(old: old, next: 0, refreshed: refreshed), 0)
    XCTAssertEqual(nativeBoundaryAfterFetchingHead(old: old, next: 3, refreshed: refreshed, headSize: 20), 20)
    XCTAssertEqual(nativeBoundaryAfterFetchingHead(old: old, next: 25, refreshed: refreshed, headSize: 20), 26)
    XCTAssertEqual(nativeBoundaryAfterFetchingHead(old: [], next: 0, refreshed: refreshed, headSize: 20), 20)
  }

  func testPartialDeleteTracksOnlyConfirmedServerDeletions() {
    let error = NativeDeleteOperationError.partial(failures: ["本机删除失败"], deletedServerIDs: ["deleted"])
    XCTAssertEqual(error.deletedServerIDs, ["deleted"])
    let serverFailure = NativeDeleteOperationError.partial(failures: ["云端删除失败"], deletedServerIDs: [])
    XCTAssertTrue(serverFailure.deletedServerIDs.isEmpty)
  }

  func testSyncCacheDoesNotCrossAccountsOrLoadLegacyUnscopedEntries() {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = NativeSyncCacheStore(directory: directory)
    store.configure(server: "https://photos.example/", userId: "alice")
    store.update(matches: ["local": "alice-photo"], checked: ["local"], newChecksums: ["local": String(repeating: "A", count: 27) + "="])
    store.configure(server: "https://photos.example/", userId: "bob")
    XCTAssertNil(store.serverID(for: "local"))
    XCTAssertTrue(store.checkedIDs.isEmpty)
    store.configure(server: "https://other.example", userId: "alice")
    XCTAssertNil(store.serverID(for: "local"))
    store.configure(server: "https://photos.example", userId: "alice")
    XCTAssertEqual(store.serverID(for: "local"), "alice-photo")
    store.configure(server: "https://photos.example", userId: nil)
    XCTAssertNil(store.serverID(for: "local"))
    store.configure(server: "https://photos.example", userId: "bob")
    store.update(matches: ["local": "bob-photo"], expectedIdentity: "https://photos.example|alice")
    XCTAssertNil(store.serverID(for: "local"))
    store.clear()
    store.configure(server: "https://photos.example", userId: "bob")
    XCTAssertNil(store.serverID(for: "local"))
  }

  func testVideoFileClassificationForSaveToPhotos() {
    XCTAssertTrue(nativeIsVideoFile(URL(fileURLWithPath: "/tmp/movie.MOV")))
    XCTAssertTrue(nativeIsVideoFile(URL(fileURLWithPath: "/tmp/movie.mp4")))
    XCTAssertFalse(nativeIsVideoFile(URL(fileURLWithPath: "/tmp/image.heic")))
  }

  func testCloudSyncBadgeDistinguishesUnverifiedFromVerifiedUnmatched() {
    let local = NativeDeviceAsset(id: "local", date: .distantPast, isVideo: false, contentVersion: 0)
    let item = NativeGridItem(server: nil, local: local)
    XCTAssertEqual(item.cloudSymbol(matchedServerIDs: [:], checkedIDs: []), "questionmark.icloud")
    XCTAssertEqual(item.cloudSymbol(matchedServerIDs: [:], checkedIDs: ["local"]), "icloud.slash")
    XCTAssertEqual(item.cloudSymbol(matchedServerIDs: ["local": "server"], checkedIDs: ["local"]), "checkmark.icloud")
  }
}

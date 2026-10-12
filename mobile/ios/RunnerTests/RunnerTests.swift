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

  func testPhotosPinchCellSizeIsContinuousAndClamped() {
    XCTAssertEqual(nativeClampedPhotosCellSize(100, magnification: 1), 100, accuracy: 0.001)
    XCTAssertEqual(nativeClampedPhotosCellSize(100, magnification: 1.5), 150, accuracy: 0.001)
    XCTAssertEqual(nativeClampedPhotosCellSize(100, magnification: 0.5), 72, accuracy: 0.001)
    XCTAssertEqual(nativeClampedPhotosCellSize(300, magnification: 2), 320, accuracy: 0.001)
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

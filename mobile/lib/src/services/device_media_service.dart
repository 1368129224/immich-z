import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

/// Thin wrapper over `photo_manager` exposing exactly the pieces the backup
/// pipeline and the "on this device" browser need.
class DeviceMediaService {
  /// Requests the platform permission needed to enumerate the gallery.
  ///
  /// Android 13+ needs granular media permissions; older versions need storage.
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth || result.hasAccess;
  }

  Future<PermissionState> currentPermission() =>
      PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(),
      );

  /// Every album (folder / collection) on the device.
  Future<List<AssetPathEntity>> getAlbums({
    bool onlyAll = false,
  }) async {
    if (!await _ensureAccess()) return <AssetPathEntity>[];
    final filter = FilterOptionGroup(
      containsPathModified: true,
      createTimeCond: DateTimeCond.def(),
      orders: [OrderOption(type: OrderOptionType.createDate, asc: false)],
    );
    return PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
      onlyAll: onlyAll,
      filterOption: filter,
    );
  }

  /// Assets inside one album, newest first, paged.
  Future<List<AssetEntity>> getAssetsInAlbum(
    AssetPathEntity album, {
    int page = 0,
    int pageSize = 200,
  }) =>
      album.getAssetListPaged(page: page, size: pageSize);

  /// The single "All" / "Recents" collection.
  Future<AssetPathEntity?> getCameraRoll() async {
    final albums = await getAlbums(onlyAll: true);
    if (albums.isEmpty) return null;
    for (final a in albums) {
      if (a.isAll) return a;
    }
    return albums.first;
  }

  Future<File?> fileFor(AssetEntity asset) => asset.file;

  Future<File?> originFileFor(AssetEntity asset) => asset.originFile;

  Future<Uint8List?> thumbnailFor(
    AssetEntity asset, {
    int width = 256,
    int height = 256,
  }) =>
      asset.thumbnailDataWithSize(
        ThumbnailSize(width, height),
        quality: 80,
      );

  /// A checksum-stable fingerprint used for server-side duplicate detection.
  /// Prefers a content hash when the platform exposes one (Android MediaStore
  /// `dateModified` + size + name is used as a cheaper fallback).
  Future<String> checksumFor(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return asset.id;
    final stat = await file.stat();
    return '${asset.id}:${stat.size}:${asset.createDateTime.millisecondsSinceEpoch}';
  }

  Future<bool> _ensureAccess() async {
    final state = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    if (state.isAuth || state.hasAccess) return true;
    return requestPermission();
  }
}

final deviceMediaProvider = Provider<DeviceMediaService>(
  (ref) => DeviceMediaService(),
);

/// The device albums list, refreshed on demand.
final deviceAlbumsProvider =
    FutureProvider<List<AssetPathEntity>>((ref) async {
  return ref.watch(deviceMediaProvider).getAlbums();
});

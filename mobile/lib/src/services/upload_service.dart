import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/generated/client.dart';
import '../api/generated/models.dart';
import 'device_media_service.dart';

enum UploadState {
  pending,
  uploading,
  done,
  duplicate,
  failed,
  canceled,
}

/// One queued upload.
class UploadItem {
  UploadItem({
    required this.localId,
    required this.filename,
    required this.createdAt,
    this.albumIds = const <String>[],
    this.state = UploadState.pending,
    this.progress = 0,
    this.error,
    this.remoteAssetId,
    this.fileSize,
    this.isLivePhotoVideo = false,
    this.parentLocalId,
  });

  final String localId;
  final String filename;
  final DateTime createdAt;
  final List<String> albumIds;
  final UploadState state;
  final double progress;
  final String? error;

  final String? remoteAssetId;
  final int? fileSize;
  final bool isLivePhotoVideo;
  final String? parentLocalId;

  UploadItem copyWith({
    UploadState? state,
    double? progress,
    String? error,
    String? remoteAssetId,
    bool clearError = false,
  }) =>
      UploadItem(
        localId: localId,
        filename: filename,
        createdAt: createdAt,
        albumIds: albumIds,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        error: clearError ? null : (error ?? this.error),
        remoteAssetId: remoteAssetId ?? this.remoteAssetId,
        fileSize: fileSize,
        isLivePhotoVideo: isLivePhotoVideo,
        parentLocalId: parentLocalId,
      );
}

/// Snapshot of the whole queue, surfaced in the backup screens.
class UploadQueueState {
  UploadQueueState({
    this.items = const <UploadItem>[],
    this.isRunning = false,
    this.total = 0,
    this.completed = 0,
    this.lastError,
    this.lastSync,
  });

  final List<UploadItem> items;
  final bool isRunning;
  final int total;
  final int completed;
  final String? lastError;
  final DateTime? lastSync;

  int get pending => items.where((i) => i.state == UploadState.pending).length;
  int get failed => items.where((i) => i.state == UploadState.failed).length;
  int get duplicates =>
      items.where((i) => i.state == UploadState.duplicate).length;

  double get overallProgress =>
      total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);

  UploadQueueState copyWith({
    List<UploadItem>? items,
    bool? isRunning,
    int? total,
    int? completed,
    String? lastError,
    DateTime? lastSync,
    bool clearError = false,
  }) =>
      UploadQueueState(
        items: items ?? this.items,
        isRunning: isRunning ?? this.isRunning,
        total: total ?? this.total,
        completed: completed ?? this.completed,
        lastError: clearError ? null : (lastError ?? this.lastError),
        lastSync: lastSync ?? this.lastSync,
      );
}

/// Which device albums participate in the backup.
class BackupSelection {
  BackupSelection({
    this.enabled = false,
    this.albumIds = const <String>[],
    this.requireWifi = true,
    this.requireCharging = false,
  });

  final bool enabled;
  final List<String> albumIds;
  final bool requireWifi;
  final bool requireCharging;
}

final backupSelectionProvider =
    StateNotifierProvider<BackupSelectionController, BackupSelection>((ref) {
  return BackupSelectionController();
});

class BackupSelectionController extends StateNotifier<BackupSelection> {
  BackupSelectionController() : super(BackupSelection()) {
    _load();
  }

  static const _kEnabled = 'backup_enabled';
  static const _kAlbums = 'backup_album_ids';
  static const _kWifi = 'backup_require_wifi';
  static const _kCharging = 'backup_require_charging';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = BackupSelection(
      enabled: prefs.getBool(_kEnabled) ?? false,
      albumIds: prefs.getStringList(_kAlbums) ?? <String>[],
      requireWifi: prefs.getBool(_kWifi) ?? true,
      requireCharging: prefs.getBool(_kCharging) ?? false,
    );
  }

  Future<void> setEnabled(bool v) async {
    state = BackupSelection(
      enabled: v,
      albumIds: state.albumIds,
      requireWifi: state.requireWifi,
      requireCharging: state.requireCharging,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, v);
  }

  Future<void> setAlbums(List<String> ids) async {
    state = BackupSelection(
      enabled: state.enabled,
      albumIds: ids,
      requireWifi: state.requireWifi,
      requireCharging: state.requireCharging,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAlbums, ids);
  }

  Future<void> setRequireWifi(bool v) async {
    state = BackupSelection(
      enabled: state.enabled,
      albumIds: state.albumIds,
      requireWifi: v,
      requireCharging: state.requireCharging,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWifi, v);
  }

  Future<void> setRequireCharging(bool v) async {
    state = BackupSelection(
      enabled: state.enabled,
      albumIds: state.albumIds,
      requireWifi: state.requireWifi,
      requireCharging: v,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCharging, v);
  }
}

/// The upload engine: scans the selected device albums, asks the server which
/// assets it already has (`/assets/bulk-upload-check`), then streams the rest up
/// through `POST /assets`.
class UploadService {
  UploadService(this._media);

  final DeviceMediaService _media;

  static const _kBackupMarker = 'backup_markers';

  /// Local ids already uploaded, so a rescan never re-uploads the same file.
  Future<Set<String>> _readMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBackupMarker);
    if (raw == null) return <String>{};
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => e.toString())
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _writeMarkers(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBackupMarker, jsonEncode(ids.toList()));
  }

  /// Builds the queue without uploading anything.
  Future<List<UploadItem>> buildQueue(List<String> albumIds) async {
    final albums = await _media.getAlbums();
    final selected = albums.where((a) => albumIds.contains(a.id)).toList();
    if (selected.isEmpty) return <UploadItem>[];

    final markers = await _readMarkers();
    final items = <UploadItem>[];
    for (final album in selected) {
      var page = 0;
      while (true) {
        final assets = await _media.getAssetsInAlbum(album, page: page);
        if (assets.isEmpty) break;
        for (final a in assets) {
          if (markers.contains(a.id)) continue;
          items.add(
            UploadItem(
              localId: a.id,
              filename: a.title ?? '${a.id}.jpg',
              createdAt: a.createDateTime,
              albumIds: [album.id],
            ),
          );
        }
        page++;
        if (assets.length < 200) break;
      }
    }
    return items;
  }

  /// Runs the queue. `onProgress` fires after each asset so the UI stays live.
  Future<void> run({
    required ImmichApiClient client,
    required List<UploadItem> queue,
    required void Function(UploadQueueState) onProgress,
    required List<String> Function(String localId) albumIdsFor,
    bool Function()? shouldCancel,
  }) async {
    var completed = 0;
    var running = List<UploadItem>.of(queue);
    onProgress(
      UploadQueueState(
        items: running,
        isRunning: true,
        total: queue.length,
        completed: 0,
      ),
    );

    final markers = await _readMarkers();

    // Ask the server which of these it already has (deduplication).
    final checks = <AssetBulkUploadCheckItem>[];
    for (final item in running) {
      final asset = await AssetEntity.fromId(item.localId);
      final checksum = asset == null
          ? item.localId
          : await _media.checksumFor(asset);
      checks.add(
        AssetBulkUploadCheckItem(id: item.localId, checksum: checksum),
      );
    }

    final known = <String, bool>{};
    try {
      final res = await client.checkBulkUpload(
        body: AssetBulkUploadCheckDto(assets: checks),
      );
      for (final r in res.results ?? []) {
        known[r.id ?? ''] =
            r.action == AssetUploadAction.reject;
      }
    } catch (_) {
      // Offline or unsupported: proceed and let the server reject duplicates.
    }

    for (var i = 0; i < running.length; i++) {
      if (shouldCancel?.call() ?? false) break;
      final item = running[i];

      if (known[item.localId] == true) {
        markers.add(item.localId);
        running[i] = item.copyWith(state: UploadState.duplicate);
        completed++;
        onProgress(
          UploadQueueState(
            items: List.of(running),
            isRunning: true,
            total: queue.length,
            completed: completed,
          ),
        );
        continue;
      }

      try {
        running[i] = item.copyWith(state: UploadState.uploading, progress: 0);
        onProgress(
          UploadQueueState(
            items: List.of(running),
            isRunning: true,
            total: queue.length,
            completed: completed,
          ),
        );

        final asset = await AssetEntity.fromId(item.localId);
        if (asset == null) {
          running[i] = item.copyWith(
            state: UploadState.failed,
            error: 'Local asset disappeared',
          );
          completed++;
          continue;
        }

        final file = await asset.file;
        if (file == null) {
          // iCloud-only assets have no local file until downloaded.
          running[i] = item.copyWith(
            state: UploadState.failed,
            error: 'Not downloaded from iCloud',
          );
          completed++;
          continue;
        }

        final length = await file.length();
        final bytes = await file.readAsBytes();
        final res = await client.uploadAsset(
          bytes,
          filename: item.filename,
          deviceAssetId: item.localId,
          deviceId: 'immich-z-${Platform.operatingSystem}',
          fileCreatedAt: item.createdAt,
          fileModifiedAt: await asset.modifiedDateTime,
          isFavorite: false,
          onSendProgress: (sent, total) {
            final p = total == 0 ? 0.0 : sent / total;
            running[i] = running[i].copyWith(
              state: UploadState.uploading,
              progress: p.clamp(0.0, 1.0),
            );
            onProgress(
              UploadQueueState(
                items: List.of(running),
                isRunning: true,
                total: queue.length,
                completed: completed,
              ),
            );
          },
        );

        markers.add(item.localId);
        running[i] = item.copyWith(
          state: UploadState.done,
          progress: 1,
          remoteAssetId: res.id,
        );
        completed++;
      } catch (e) {
        running[i] = item.copyWith(
          state: UploadState.failed,
          error: e.toString(),
        );
        completed++;
      }

      onProgress(
        UploadQueueState(
          items: List.of(running),
          isRunning: true,
          total: queue.length,
          completed: completed,
        ),
      );
    }

    await _writeMarkers(markers);
    onProgress(
      UploadQueueState(
        items: List.of(running),
        isRunning: false,
        total: queue.length,
        completed: completed,
        lastSync: DateTime.now(),
      ),
    );
  }
}

final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(ref.watch(deviceMediaProvider));
});

/// Holds the in-memory queue + run state for the UI.
class UploadQueueController extends StateNotifier<UploadQueueState> {
  UploadQueueController(this._service) : super(UploadQueueState());

  final UploadService _service;
  bool _cancelRequested = false;

  Future<void> refresh(List<String> albumIds) async {
    final items = await _service.buildQueue(albumIds);
    state = UploadQueueState(items: items, total: items.length);
  }

  Future<void> start(ImmichApiClient client) async {
    if (state.isRunning) return;
    _cancelRequested = false;
    if (state.items.isEmpty) {
      return;
    }
    await _service.run(
      client: client,
      queue: state.items,
      albumIdsFor: (_) => const <String>[],
      onProgress: (s) => state = s,
      shouldCancel: () => _cancelRequested,
    );
  }

  void cancel() => _cancelRequested = true;

  Future<void> clearFinished() async {
    state = UploadQueueState(
      items: state.items
          .where((i) =>
              i.state == UploadState.pending || i.state == UploadState.failed)
          .toList(),
      total: state.total,
      completed: state.completed,
      lastSync: state.lastSync,
    );
  }
}

final uploadQueueProvider =
    StateNotifierProvider<UploadQueueController, UploadQueueState>((ref) {
  return UploadQueueController(ref.watch(uploadServiceProvider));
});

/// Cache directory used by downloads and share-intent staging.
final cacheDirProvider = FutureProvider<Directory>((ref) async {
  return getTemporaryDirectory();
});

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../api/generated/client.dart';
import 'device_media_service.dart';
import 'notification_service.dart';
import 'upload_service.dart';

/// Task names registered with `workmanager`.
const String kBackupTaskName = 'immich.z/backup';
const String kSyncTaskName = 'immich.z/sync';

/// Entry point for the background isolate. Must be a top-level function.
@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case kBackupTaskName:
          return await _runBackup();
        case kSyncTaskName:
          return await _runSync();
        default:
          return true;
      }
    } catch (e, st) {
      debugPrint('background task $task failed: $e\n$st');
      return false;
    }
  });
}

const _kServerUrl = 'server_url';
const _kApiEndpoint = 'api_endpoint';
const _kAccessToken = 'access_token';
const _kAlbumIds = 'backup_album_ids';

/// Reads a persisted session without touching the secure keystore: the
/// background isolate shares `SharedPreferences` with the UI isolate, and the
/// token is stored there as well by [BackgroundService.persistSession] so the
/// isolate can authenticate independently.
Future<ImmichApiClient?> _clientFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_kAccessToken);
  final api = prefs.getString(_kApiEndpoint);
  if (token == null || api == null || token.isEmpty || api.isEmpty) {
    return null;
  }
  return ImmichApiClient(baseUrl: api, accessToken: token);
}

Future<bool> _runBackup() async {
  final client = await _clientFromPrefs();
  if (client == null) return true;

  final prefs = await SharedPreferences.getInstance();
  final ids = prefs.getStringList(_kAlbumIds) ?? <String>[];
  if (ids.isEmpty) return true;

  final media = DeviceMediaService();
  final service = UploadService(media);
  final queue = await service.buildQueue(ids);
  if (queue.isEmpty) return true;

  await NotificationService.initialize();
  await NotificationService.showUploadProgress(completed: 0, total: queue.length);

  var completed = 0;
  await service.run(
    client: client,
    queue: queue,
    albumIdsFor: (_) => const <String>[],
    onProgress: (s) {
      completed = s.completed;
    },
  );

  await NotificationService.cancelUpload();
  await NotificationService.showUploadComplete(completed);
  return true;
}

/// Periodic light sync: refresh the cached bucket list so the timeline opens
/// instantly even before its first network round-trip.
Future<bool> _runSync() async {
  final client = await _clientFromPrefs();
  if (client == null) return true;
  try {
    final buckets = await client.getTimeBuckets();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cached_buckets',
      jsonEncode(buckets.map((b) => b.toJson()).toList()),
    );
  } catch (_) {
    return false;
  }
  return true;
}

/// Scheduling helpers used by the settings screen.
class BackgroundService {
  static const _kEnabled = 'background_backup_enabled';

  /// Mirrors the session into `SharedPreferences` so the background isolate can
  /// authenticate without cross-isolate keystore access.
  static Future<void> persistSession({
    required String serverUrl,
    required String apiEndpoint,
    required String accessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kServerUrl, serverUrl);
    await prefs.setString(_kApiEndpoint, apiEndpoint);
    await prefs.setString(_kAccessToken, accessToken);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kServerUrl);
    await prefs.remove(_kApiEndpoint);
    await prefs.remove(_kAccessToken);
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  /// Registers the periodic backup task.
  ///
  /// iOS only supports the "background fetch" frequency here, so the platform
  /// decides when to actually run it; Android honours the 15-minute period.
  static Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
    await Workmanager().registerPeriodicTask(
      'immich-z-backup',
      kBackupTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresCharging: false,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    await Workmanager().registerPeriodicTask(
      'immich-z-sync',
      kSyncTaskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
    await Workmanager().cancelByUniqueName('immich-z-backup');
    await Workmanager().cancelByUniqueName('immich-z-sync');
  }

  /// Starts a one-shot backup immediately, used by the manual "Backup now"
  /// action and by the share-intent receiver.
  static Future<void> runOnce() async {
    if (Platform.isAndroid) {
      await Workmanager().registerOneOffTask(
        'immich-z-backup-once',
        kBackupTaskName,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } else {
      await _runBackup();
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Channels used by the upload/backup notifications.
class NotificationService {
  static const _uploadChannelId = 'immich_z_upload';
  static const _uploadChannelName = 'Backup';
  static const _uploadChannelDescription =
      'Progress notifications while photos are uploaded to the server.';

  static const _syncChannelId = 'immich_z_sync';
  static const _syncChannelName = 'Sync';

  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await plugin.initialize(initSettings);

    final android = plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _uploadChannelId,
        _uploadChannelName,
        description: _uploadChannelDescription,
        importance: Importance.low,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _syncChannelId,
        _syncChannelName,
        description: 'Background sync status',
        importance: Importance.low,
      ),
    );
    await android?.requestNotificationsPermission();
  }

  /// Indeterminate progress notification shown while the queue drains.
  static Future<void> showUploadProgress({
    required int completed,
    required int total,
  }) async {
    final title = total == 0 ? 'Backing up' : 'Backing up ($completed/$total)';
    await plugin.show(
      1001,
      title,
      'Uploading new photos and videos',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _uploadChannelId,
          _uploadChannelName,
          channelDescription: _uploadChannelDescription,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: total,
          progress: completed,
          indeterminate: total == 0,
          ongoing: true,
          autoCancel: false,
          category: AndroidNotificationCategory.progress,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: false),
      ),
    );
  }

  static Future<void> showUploadComplete(int count) async {
    await plugin.show(
      1002,
      'Backup complete',
      '$count item(s) uploaded',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _uploadChannelId,
          _uploadChannelName,
          channelDescription: _uploadChannelDescription,
          onlyAlertOnce: true,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  static Future<void> cancelUpload() async {
    await plugin.cancel(1001);
  }
}

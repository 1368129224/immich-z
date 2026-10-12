import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Channels used by the upload/backup notifications.
class NotificationService {
  static final plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await plugin.initialize(initSettings);
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
      const NotificationDetails(
        iOS: DarwinNotificationDetails(presentAlert: false),
      ),
    );
  }

  static Future<void> showUploadComplete(int count) async {
    await plugin.show(
      1002,
      'Backup complete',
      '$count item(s) uploaded',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(presentAlert: true),
      ),
    );
  }

  static Future<void> cancelUpload() async {
    await plugin.cancel(1001);
  }
}

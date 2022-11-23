import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationConfig {
  static const channelId = 'team_mail_channel_id';
  static const channelKey = 'team_mail_channel_key';
  static const channelName = 'Team Mail notifications';
  static const channelDescription = 'Team Mail notifications';

  static const iosInitializationSettings = DarwinInitializationSettings();

  static const androidInitializationSettings = AndroidInitializationSettings('background');

  static const androidNotificationChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.max,
    enableLights: true,
  );

  static const pushNotificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      visibility: NotificationVisibility.public,
      importance: Importance.max,
      ledOnMs: 100,
      ledOffMs: 1000,
      category: AndroidNotificationCategory.message,
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    ),
  );
}
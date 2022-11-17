import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const channelId = 'team_mail_channel_id';
const channelKey = 'team_mail_channel_key';
const channelName = 'Team Mail notifications';
const channelDescription = 'Team Mail notifications';

final iosInitializationSettings = DarwinInitializationSettings(
  notificationCategories: [
    DarwinNotificationCategory(
      channelId,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          channelKey,
          channelName,
          options: {
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
    ),
  ],
  onDidReceiveLocalNotification:
      (int id, String? title, String? body, String? payload) {},
);

const androidInitializationSettings =
AndroidInitializationSettings('background');

const androidChannel = AndroidNotificationChannel(
  channelId,
  channelName,
  description: channelDescription,
  importance: Importance.max,
  enableLights: true,
);

const pushNotificationDetails = NotificationDetails(
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
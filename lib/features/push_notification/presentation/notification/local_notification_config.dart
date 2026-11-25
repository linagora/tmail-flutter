import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationConfig {
  static const String NOTIFICATION_CHANNEL = 'New Email';

  static const iosInitializationSettings = DarwinInitializationSettings();
  static const androidInitializationSettings = AndroidInitializationSettings('notification_icon');

  LocalNotificationConfig._internal();

  static final LocalNotificationConfig _instance = LocalNotificationConfig._internal();

  static LocalNotificationConfig get instance => _instance;

  NotificationDetails generateNotificationDetails({
    StyleInformation? styleInformation,
    bool setAsGroup = false,
    String? groupId,
    String? tag,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        NOTIFICATION_CHANNEL,
        NOTIFICATION_CHANNEL,
        groupKey: groupId,
        tag: tag,
        // Email subject, sender and preview are attacker-controlled and
        // confidential: honour the "hide sensitive content" lock screen
        // setting instead of forcing full display.
        visibility: NotificationVisibility.private,
        importance: Importance.max,
        priority: Priority.high,
        setAsGroupSummary: setAsGroup,
        styleInformation: styleInformation,
        // Only the group summary alerts, each email notification is posted silently under it.
        silent: !setAsGroup,
        groupAlertBehavior: setAsGroup
          ? GroupAlertBehavior.summary
          : GroupAlertBehavior.all,
        channelShowBadge: true,
        showWhen: true,
        largeIcon: const DrawableResourceAndroidBitmap('ic_large_notification')
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        threadIdentifier: NOTIFICATION_CHANNEL
      ),
    );
  }
}
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
    bool silent = false,
    String? groupId,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        NOTIFICATION_CHANNEL,
        NOTIFICATION_CHANNEL,
        groupKey: groupId,
        visibility: NotificationVisibility.public,
        importance: Importance.max,
        priority: Priority.high,
        setAsGroupSummary: setAsGroup,
        styleInformation: styleInformation,
        silent: silent,
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
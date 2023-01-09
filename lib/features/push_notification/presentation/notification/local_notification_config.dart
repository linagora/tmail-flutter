import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationConfig {
  static const _groupId = 'team_mail_notification_group_id';
  static const _groupName = 'team_mail_notification_group_name';
  static const _groupDescription = 'Team Mail group notifications';
  static const _channelId = 'team_mail_notification_channel_id';
  static const _channelName = 'Team Mail notifications';
  static const _channelDescription = 'Team Mail notifications';
  static const notificationTitle = 'Team Mail';
  static const notificationMessage = 'You have new messages';

  static const iosInitializationSettings = DarwinInitializationSettings();

  static const androidInitializationSettings = AndroidInitializationSettings('ic_notification');

  static const androidNotificationChannel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    groupId: _groupId,
    importance: Importance.max,
    showBadge: true
  );

  static const androidNotificationChannelGroup = AndroidNotificationChannelGroup(
    _groupId,
    _groupName,
    description: _groupDescription
  );

  LocalNotificationConfig._internal();

  static final LocalNotificationConfig _instance = LocalNotificationConfig._internal();

  static LocalNotificationConfig get instance => _instance;

  NotificationDetails generateNotificationDetails({StyleInformation? styleInformation, bool setAsGroup = false}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        androidNotificationChannel.id,
        androidNotificationChannel.name,
        channelDescription: androidNotificationChannel.description,
        groupKey: androidNotificationChannel.groupId,
        visibility: NotificationVisibility.public,
        importance: Importance.max,
        priority: Priority.high,
        setAsGroupSummary: setAsGroup,
        styleInformation: styleInformation,
        channelShowBadge: true,
        showWhen: true,
        largeIcon: const DrawableResourceAndroidBitmap('ic_large_notification')
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        threadIdentifier: _channelId
      ),
    );
  }
}
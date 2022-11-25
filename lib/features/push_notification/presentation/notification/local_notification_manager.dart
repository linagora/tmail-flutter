
import 'dart:io';

import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_config.dart';

class LocalNotificationManager {

  LocalNotificationManager._internal();

  static final LocalNotificationManager _instance = LocalNotificationManager._internal();

  static LocalNotificationManager get instance => _instance;

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool notificationsEnabled = false;

  Future<void> setUp() async {
    try {
      await _initLocalNotification();
      _checkLocalNotificationPermission();
      if (Platform.isAndroid) {
        await _createAndroidNotificationChannelGroup();
        await _createAndroidNotificationChannel();
      }
    } catch (e) {
      logError('LocalNotificationManager::setUp(): ERROR: ${e.toString()}');
    }
  }

  Future<bool?> _initLocalNotification() async {
    return await _localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: LocalNotificationConfig.androidInitializationSettings,
        iOS: LocalNotificationConfig.iosInitializationSettings
      ),
      onDidReceiveNotificationResponse: _handleReceiveNotificationResponse
    );
  }

  void _handleReceiveNotificationResponse(NotificationResponse response) {
    log('LocalNotificationManager::handleReceiveNotificationResponse(): $response');
  }

  void _checkLocalNotificationPermission() async {
    if (notificationsEnabled) {
      return;
    }

    if (Platform.isAndroid) {
      final granted = await _isAndroidPermissionGranted();
      if (!granted) {
        notificationsEnabled = await _requestPermissions();
      }
    } else {
      notificationsEnabled = await _requestPermissions();
    }
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.areNotificationsEnabled() ?? false;
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      return await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission() ?? false;
    } else {
      return await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
  }

  Future<void> _createAndroidNotificationChannel() async {
    return await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(LocalNotificationConfig.androidNotificationChannel);
  }

  Future<void> _createAndroidNotificationChannelGroup() async {
    await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
      .createNotificationChannelGroup(LocalNotificationConfig.androidNotificationChannelGroup);
  }

  void showPushNotification({
    required String id,
    required String title,
    String? message,
    EmailAddress? emailAddress,
    String? payload
  }) async {
    final inboxStyleInformation = InboxStyleInformation(
      [title, message ?? ''],
      contentTitle: (emailAddress?.asString() ?? '').addBlockTag('b'),
      summaryText: (emailAddress?.asString() ?? '').addBlockTag('b'),
      htmlFormatTitle: true,
      htmlFormatContent: true,
      htmlFormatContentTitle: true,
      htmlFormatSummaryText: true,
    );

    await _localNotificationsPlugin.show(
      id.hashCode,
      title.addBlockTag('b'),
      message ?? '',
      LocalNotificationConfig.instance.generateNotificationDetails(styleInformation: inboxStyleInformation),
      payload: payload
    );
  }

  void groupPushNotification() async {
    final activeNotifications = await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();

    if (activeNotifications != null && activeNotifications.isNotEmpty) {
      await _localNotificationsPlugin.show(
        1995,
        '',
        '',
        LocalNotificationConfig.instance.generateNotificationDetails(setAsGroup: true)
      );
    }
  }
}
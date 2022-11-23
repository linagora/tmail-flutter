
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_config.dart';

@pragma('vm:entry-point')
void _handleReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
  log('LocalNotificationManager::_handleReceiveBackgroundNotificationResponse():notificationResponse: $notificationResponse');
}

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
        await _createAndroidNotificationChannels();
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
      onDidReceiveNotificationResponse: _handleReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _handleReceiveBackgroundNotificationResponse
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

  Future<void> _createAndroidNotificationChannels() async {
    return await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(LocalNotificationConfig.androidNotificationChannel);
  }

  void showPushNotification({String? title, String? message, String? payload}) async {
    final generateNotificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _localNotificationsPlugin.show(
      generateNotificationId,
      title ?? LocalNotificationConfig.channelName,
      message ?? LocalNotificationConfig.channelDescription,
      LocalNotificationConfig.pushNotificationDetails,
      payload: payload
    );
  }
}

import 'dart:async';

import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_config.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class LocalNotificationManager {

  late StreamController<NotificationResponse> localNotificationsController;

  LocalNotificationManager._internal() {
    localNotificationsController = StreamController<NotificationResponse>.broadcast();
  }

  static final LocalNotificationManager _instance = LocalNotificationManager._internal();

  static LocalNotificationManager get instance => _instance;

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _notificationsEnabled = false;
  bool _isNotificationClickedOnTerminate = false;

  Stream<NotificationResponse> get localNotificationStream => localNotificationsController.stream;

  NotificationAppLaunchDetails? _notificationAppLaunchDetails;

  Future<void> setUp() async {
    try {
      await _initLocalNotification();
      await _checkLocalNotificationPermission();
      if (PlatformInfo.isAndroid) {
        await _createAndroidNotificationChannelGroup();
        await _createAndroidNotificationChannel();
      }
    } catch (e) {
      logError('LocalNotificationManager::setUp(): ERROR: ${e.toString()}');
    }
  }

  Future<NotificationResponse?> getCurrentNotificationResponse() async {
    try {
      _notificationAppLaunchDetails = await _localNotificationsPlugin.getNotificationAppLaunchDetails();
      return _notificationAppLaunchDetails?.notificationResponse;
    } catch (e) {
      logError('LocalNotificationManager::getCurrentNotificationResponse(): ERROR: ${e.toString()}');
    }
    return null;
  }

  set activatedNotificationClickedOnTerminate(bool clicked) => _isNotificationClickedOnTerminate = clicked;

  bool get isNotificationClickedOnTerminate => _isNotificationClickedOnTerminate;

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
    log('LocalNotificationManager::handleReceiveNotificationResponse():payload: ${response.payload}');
    if (response.notificationResponseType == NotificationResponseType.selectedNotification) {
      if (!localNotificationsController.isClosed) {
        localNotificationsController.add(response);
      }
    }
  }

  Future<void> _checkLocalNotificationPermission() async {
    if (_notificationsEnabled) {
      return Future.value(null);
    }

    if (PlatformInfo.isAndroid) {
      final granted = await _isAndroidPermissionGranted();
      if (!granted) {
        _notificationsEnabled = await _requestPermissions();
      } else {
        _notificationsEnabled = granted;
      }
    } else if (PlatformInfo.isIOS) {
      _notificationsEnabled = await _requestPermissions();
    }
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.areNotificationsEnabled() ?? false;
  }

  Future<bool> _requestPermissions() async {
    if (PlatformInfo.isAndroid) {
      return await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission() ?? false;
    } else if (PlatformInfo.isIOS) {
      return await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    } else {
      return false;
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
    String? payload,
    bool isInboxStyle = true
  }) async {
    if (isInboxStyle) {
      final inboxStyleInformation = InboxStyleInformation(
        [message?.addBlockTag('p', attribute: 'style="color:#6D7885;"') ?? ''],
        htmlFormatLines: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: (emailAddress?.asString() ?? '').addBlockTag('b'),
        htmlFormatSummaryText: true,
      );

      await _localNotificationsPlugin.show(
        id.hashCode,
        title,
        message,
        LocalNotificationConfig.instance.generateNotificationDetails(styleInformation: inboxStyleInformation),
        payload: payload
      );
    } else {
      await _localNotificationsPlugin.show(
        id.hashCode,
        title,
        message,
        LocalNotificationConfig.instance.generateNotificationDetails(styleInformation: const DefaultStyleInformation(true, true)),
        payload: payload
      );
    }
  }

  Future<void> removeNotification(String id) async {
    return _localNotificationsPlugin.cancel(id.hashCode);
  }

  void groupPushNotification() async {
    if (PlatformInfo.isIOS) {
      return;
    }

    final activeNotifications = await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();

    if (activeNotifications != null && activeNotifications.isNotEmpty) {
      final inboxStyleInformation = InboxStyleInformation(
        [''],
        summaryText: currentContext != null
          ? AppLocalizations.of(currentContext!).totalNewMessagePushNotification(activeNotifications.length - 1).addBlockTag('b')
          : '${activeNotifications.length - 1} new emails'.addBlockTag('b'),
        htmlFormatSummaryText: true,
      );

      await _localNotificationsPlugin.show(
        LocalNotificationConfig.groupNotificationId,
        null,
        null,
        LocalNotificationConfig.instance.generateNotificationDetails(
          setAsGroup: true,
          styleInformation: inboxStyleInformation
        ),
      );
    }
  }

  void removeGroupPushNotification() async {
    final activeNotifications = await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();
    log('LocalNotificationManager::removeGroupPushNotification():activeNotifications: ${activeNotifications?.length}');
    if (activeNotifications == null || activeNotifications.length <= 1) {
      log('LocalNotificationManager::groupPushNotification():canceled');
      await _localNotificationsPlugin.cancel(LocalNotificationConfig.groupNotificationId);
    }
  }

  Future<void> recreateStreamController() {
    if (localNotificationsController.isClosed) {
      localNotificationsController = StreamController<NotificationResponse>.broadcast();
    }
    return Future.value();
  }

  void closeStream() {
    localNotificationsController.close();
  }
}
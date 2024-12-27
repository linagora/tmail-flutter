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

  bool _isNotificationClickedOnTerminate = false;

  Stream<NotificationResponse> get localNotificationStream => localNotificationsController.stream;

  NotificationAppLaunchDetails? _notificationAppLaunchDetails;

  Future<void> setUp({required String groupId}) async {
    try {
      final isInitialNotification = await _initLocalNotification();
      log('LocalNotificationManager::setUp:isInitialNotification: $isInitialNotification');
      await _checkLocalNotificationPermission();
      if (PlatformInfo.isAndroid) {
        await _createAndroidNotificationChannelGroup(groupId);
        await _createAndroidNotificationChannel(groupId);
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
    if (PlatformInfo.isAndroid) {
      final granted = await _isAndroidPermissionGranted();
      log('LocalNotificationManager::requestPermissionAndroid: _isAndroidPermissionGranted = $granted');
      if (!granted) {
        await _requestPermissions();
      }
    } else if (PlatformInfo.isIOS) {
      log('LocalNotificationManager::requestPermissionIOS');
      await _requestPermissions();
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
        ?.requestNotificationsPermission() ?? false;
    } else if (PlatformInfo.isIOS) {
      return await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    } else {
      return false;
    }
  }

  Future<void> _createAndroidNotificationChannel(String groupId) async {
    return await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(AndroidNotificationChannel(
          LocalNotificationConfig.NOTIFICATION_CHANNEL,
          LocalNotificationConfig.NOTIFICATION_CHANNEL,
          groupId: groupId,
      ));
  }

  Future<void> _createAndroidNotificationChannelGroup(String groupId) async {
    await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannelGroup(AndroidNotificationChannelGroup(
          groupId,
          groupId,
      ));
  }

  Future<void> showPushNotification({
    required String id,
    required String title,
    bool silent = false,
    String? message,
    EmailAddress? emailAddress,
    String? payload,
    String? groupId,
  }) async {
    final inboxStyleInformation = InboxStyleInformation(
      [message?.addBlockTag('p', attribute: 'style="color:#6D7885;"') ?? ''],
      htmlFormatLines: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: (emailAddress?.asString() ?? '').addBlockTag('b'),
      htmlFormatSummaryText: true);

    await _localNotificationsPlugin.show(
      id.hashCode,
      title,
      message,
      LocalNotificationConfig.instance.generateNotificationDetails(
        styleInformation: inboxStyleInformation,
        groupId: groupId,
        silent: silent
      ),
      payload: payload);
  }

  Future<void> removeNotification(String id) async {
    return _localNotificationsPlugin.cancel(id.hashCode);
  }

  Future<int> getCountActiveNotificationByGroupOnAndroid({required String groupId}) async {
    final activeNotifications = await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications() ?? [];

    final listActiveNotificationByGroup = activeNotifications
      .where((notification) => notification.groupKey == groupId && notification.id != groupId.hashCode)
      .toList();
    log('LocalNotificationManager::getCountActiveNotificationByGroupOnAndroid(): groupId = $groupId | activeNotifications = ${activeNotifications.length} | listActiveNotificationByGroup = ${listActiveNotificationByGroup.length}');
    return listActiveNotificationByGroup.length;
  }

  Future<void> groupPushNotificationOnAndroid({required String groupId, required int countNotifications}) async {
    log('LocalNotificationManager::groupPushNotificationOnAndroid:groupId = $groupId');
    final inboxStyleInformation = InboxStyleInformation(
      [''],
      summaryText: currentContext != null
        ? AppLocalizations.of(currentContext!).totalNewMessagePushNotification(countNotifications).addBlockTag('b')
        : '$countNotifications new emails'.addBlockTag('b'),
      htmlFormatSummaryText: true,
    );

    await _localNotificationsPlugin.show(
      groupId.hashCode,
      null,
      null,
      LocalNotificationConfig.instance.generateNotificationDetails(
        setAsGroup: true,
        styleInformation: inboxStyleInformation,
        groupId: groupId
      ),
    );
  }

  Future<void> removeGroupPushNotification(String groupId) async {
    final activeNotifications = await _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications() ?? [];

    final listActiveNotificationByGroup = activeNotifications
      .where((notification) => notification.groupKey == groupId)
      .toList();
    log('LocalNotificationManager::removeGroupPushNotification(): activeNotifications = ${activeNotifications.length} | listActiveNotificationByGroup = ${listActiveNotificationByGroup.length}');
    if (listActiveNotificationByGroup.length <= 1) {
      log('LocalNotificationManager::groupPushNotification():canceled');
      await _localNotificationsPlugin.cancel(groupId.hashCode);
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

  Future<void> clearAllNotifications() async {
    _localNotificationsPlugin.cancelAll();
  }
}
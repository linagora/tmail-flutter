
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/broadcast_channel/broadcast_channel.dart';
import 'package:core/utils/platform_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:universal_html/html.dart' as html show MessageEvent, DomException;

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  FcmService.instance.initialStreamController();
  FcmMessageController.instance.initialize();
  FcmService.instance.handleFirebaseBackgroundMessage(message);
}

class FcmReceiver {
  FcmReceiver._internal();

  static final FcmReceiver _instance = FcmReceiver._internal();

  static FcmReceiver get instance => _instance;

  static const notificationInteractionChannel = MethodChannel('notification_interaction_channel');
  static const int MAX_COUNT_RETRY_TO_GET_FCM_TOKEN = 3;

  int _countRetryToGetFcmToken = 0;

  Future onInitialFcmListener() async {
    _countRetryToGetFcmToken = 0;
    _onForegroundMessage();
    _onBackgroundMessage();

    if (PlatformInfo.isWeb) {
      _onMessageBroadcastChannel();
      await _requestNotificationPermissionOnWeb();
    } else if (PlatformInfo.isIOS) {
      _setUpIOSNotificationInteraction();
      await _onHandleFcmToken();
    } else {
      await _onHandleFcmToken();
    }
  }

  void _setUpIOSNotificationInteraction() {
    notificationInteractionChannel.setMethodCallHandler((call) async {
      log('FcmReceiver::_setUpIOSNotificationInteraction:notificationInteractionChannel: $call');
      if (call.method == 'openEmail' && call.arguments is String) {
        log('FcmReceiver::_setUpIOSNotificationInteraction:openEmail with id = ${call.arguments}');
        FcmService.instance.handleOpenEmailFromNotification(call.arguments);
      }
    });
  }

  Future<void> _requestNotificationPermissionOnWeb() async {
    NotificationSettings notificationSetting = await FirebaseMessaging.instance.getNotificationSettings();
    log('FcmReceiver::_requestNotificationPermissionOnWeb: authorizationStatus = ${notificationSetting.authorizationStatus}');
    if (notificationSetting.authorizationStatus != AuthorizationStatus.authorized) {
      notificationSetting = await FirebaseMessaging.instance.requestPermission();
      if (notificationSetting.authorizationStatus == AuthorizationStatus.authorized) {
        await _onHandleFcmToken();
      }
    } else {
      await _onHandleFcmToken();
    }
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(FcmService.instance.handleFirebaseForegroundMessage);
  }

  void _onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  void _onMessageBroadcastChannel() {
    final broadcast = BroadcastChannel('background-message');
    broadcast.onMessage.listen((event) {
      if (event is html.MessageEvent) {
        FcmService.instance.handleMessageEventBroadcastChannel(event);
      }
    });
  }

  Future<String?> _getInitialToken() async {
    try {
      final vapidKey = PlatformInfo.isWeb ? AppConfig.fcmVapidPublicKeyWeb : null;
      final token = await FirebaseMessaging.instance.getToken(vapidKey: vapidKey);
      log('FcmReceiver::_getInitialToken:token: $token');
      return token;
    } catch (e) {
      logError('FcmReceiver::_getInitialToken: TYPE = ${e.runtimeType} | Exception = $e');
      if (PlatformInfo.isWeb
          && e is html.DomException
          && _countRetryToGetFcmToken < MAX_COUNT_RETRY_TO_GET_FCM_TOKEN) {
        return await _retryGetToken();
      }
      return null;
    }
  }

  Future<String?> _retryGetToken() async {
    _countRetryToGetFcmToken++;
    log('FcmReceiver::_retryGetToken: CountRetry = $_countRetryToGetFcmToken');
    return await _getInitialToken();
  }

  Future _onHandleFcmToken() async {
    final token = await _getInitialToken();
    FcmService.instance.handleToken(token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      log('FcmReceiver::_onHandleFcmToken:onTokenRefresh: $newToken');
      if (newToken != token) {
        FcmService.instance.handleToken(newToken);
      }
    });
  }

  Future<Map<String, dynamic>?> getIOSInitialNotificationInfo() async {
    try {
      final notificationInfo = await notificationInteractionChannel.invokeMethod('getInitialNotificationInfo');
      log('FcmReceiver::getIOSInitialNotificationInfo:notificationInfo: $notificationInfo');
      if (notificationInfo != null && notificationInfo is Map<String, dynamic>) {
        return notificationInfo;
      }
      return null;
    } catch (e) {
      logError('FcmReceiver::getIOSInitialNotificationInfo: Exception: $e');
      return null;
    }
  }
}
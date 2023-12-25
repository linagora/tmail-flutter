
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

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

  Future onInitialFcmListener() async {
    log('FcmReceiver::onInitialFcmListener:');
    await _onHandleFcmToken();

    _onForegroundMessage();
    _onBackgroundMessage();

    if (PlatformInfo.isIOS) {
      notificationInteractionChannel.setMethodCallHandler((call) async {
        log('FcmReceiver::onInitialFcmListener:notificationInteractionChannel: $call');
        if (call.method == 'openEmail' && call.arguments is String) {
          log('FcmReceiver::onInitialFcmListener:openEmail with id = ${call.arguments}');
          FcmService.instance.handleOpenEmailFromNotification(call.arguments);
        }
      });
    }
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(FcmService.instance.handleFirebaseForegroundMessage);
  }

  void _onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  Future<String?> _getInitialToken() async {
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: PlatformInfo.isWeb ? AppConfig.fcmVapidPublicKeyWeb : null
    );
    log('FcmReceiver::_getInitialToken:token: $token');
    return token;
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

  Future deleteFcmToken() async {
    await FirebaseMessaging.instance.deleteToken();
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
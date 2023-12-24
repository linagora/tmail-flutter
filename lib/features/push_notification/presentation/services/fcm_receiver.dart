
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  Future onInitialFcmListener() async {
    log('FcmReceiver::onInitialFcmListener:');
    await _onHandleFcmToken();

    _onForegroundMessage();
    _onBackgroundMessage();
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
}
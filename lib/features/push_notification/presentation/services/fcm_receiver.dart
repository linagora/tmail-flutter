
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  log('FcmReceiver::handleFirebaseBackgroundMessage(): ${message.data}');
  FcmService.instance.handleFirebaseBackgroundMessage(message);
}

class FcmReceiver {
  FcmReceiver._internal();

  static final FcmReceiver _instance = FcmReceiver._internal();

  static FcmReceiver get instance => _instance;

  void onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(FcmService.instance.handleFirebaseForegroundMessage);
  }

  void onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  void getFcmToken() async {
    try {
      final currentToken = await FirebaseMessaging.instance.getToken(vapidKey: AppUtils.fcmVapidPublicKey);
      log('FcmReceiver::onFcmToken():currentToken: $currentToken');
      if (BuildUtils.isWeb) {
        FcmService.instance.handleGetToken(currentToken);
      }
    } catch(e) {
      log('FcmReceiver::onFcmToken():exception: $e');
    }
  }

  void onRefreshFcmToken() {
    FirebaseMessaging.instance.onTokenRefresh.listen(FcmService.instance.handleRefreshToken);
  }
  
  void deleteFcmToken(){
    FirebaseMessaging.instance.deleteToken();
  }
}
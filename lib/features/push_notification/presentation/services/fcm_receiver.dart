
import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';

int semaphoreBackground = 0;

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  if (semaphoreBackground != 0) {
    return;
  }
  semaphoreBackground = 1;
  Future.delayed(const Duration(milliseconds: FcmService.durationMessageComing)).then((_) => semaphoreBackground = 0);

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

  void onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(FcmService.instance.handleFirebaseMessageOpenedApp);
  }

  void onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  void getFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    log('FcmReceiver::onFcmToken():token: $token');
  }
}
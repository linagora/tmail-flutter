
import 'package:firebase_core/firebase_core.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/firebase_options.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';

class FcmConfiguration {

  static void initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _initMessageListener();
  }

  static void _initMessageListener() {
    FcmReceiver.instance.onForegroundMessage();
    FcmReceiver.instance.onBackgroundMessage();
    FcmReceiver.instance.getFcmToken();
  }
}
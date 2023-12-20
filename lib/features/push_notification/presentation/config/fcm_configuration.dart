
import 'package:firebase_core/firebase_core.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/firebase_options.dart';

class FcmConfiguration {
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}
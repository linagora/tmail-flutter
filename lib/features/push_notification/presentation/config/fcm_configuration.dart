
import 'package:core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/firebase_options.dart';

class FcmConfiguration {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      logError('FcmConfiguration::initialize: Exception = $e');
    }
  }
}
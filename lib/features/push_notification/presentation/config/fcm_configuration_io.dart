/// IO-specific FCM configuration (non-web platforms).
/// Checks at runtime whether to use Firebase (mobile) or stub (desktop).

import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/firebase_options.dart';

class FcmConfiguration {
  static bool get _isMobile => Platform.isIOS || Platform.isAndroid;

  static Future<void> initialize() async {
    if (!_isMobile) {
      log('FcmConfiguration::initialize: FCM not supported on desktop, using WebSocket instead');
      return;
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      logWarning('FcmConfiguration::initialize: Exception = $e');
    }
  }
}

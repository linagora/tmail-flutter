/// Stub implementation of FCM receiver for desktop/web platforms.
/// Desktop platforms use WebSocket for push notifications instead of FCM.

import 'package:core/utils/app_logger.dart';

class FcmReceiver {
  FcmReceiver._internal();

  static final FcmReceiver _instance = FcmReceiver._internal();

  static FcmReceiver get instance => _instance;

  Future onInitialFcmListener() async {
    log('FcmReceiver::onInitialFcmListener: FCM not supported on this platform, using WebSocket instead');
  }
}

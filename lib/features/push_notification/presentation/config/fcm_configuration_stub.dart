/// Stub implementation of FCM configuration for desktop platforms.
/// Desktop platforms (Windows, macOS, Linux) use WebSocket for push notifications
/// instead of Firebase Cloud Messaging.

import 'package:core/utils/app_logger.dart';

class FcmConfiguration {
  static Future<void> initialize() async {
    log('FcmConfiguration::initialize: FCM not supported on desktop, using WebSocket instead');
  }
}

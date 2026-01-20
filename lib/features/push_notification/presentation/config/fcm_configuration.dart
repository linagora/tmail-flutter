/// Platform-specific FCM configuration.
/// - Mobile (iOS/Android): Uses Firebase Cloud Messaging
/// - Desktop (Windows/macOS/Linux): Stub - uses WebSocket instead
/// - Web: Uses WebSocket instead

export 'fcm_configuration_stub.dart'
    if (dart.library.io) 'fcm_configuration_io.dart';

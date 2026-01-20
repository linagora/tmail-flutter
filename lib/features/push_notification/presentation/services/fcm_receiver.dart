/// Platform-specific FCM receiver.
/// - Mobile (iOS/Android): Uses Firebase Cloud Messaging
/// - Desktop (Windows/macOS/Linux): Stub - uses WebSocket instead
/// - Web: Stub - uses WebSocket instead

export 'fcm_receiver_stub.dart'
    if (dart.library.io) 'fcm_receiver_io.dart';

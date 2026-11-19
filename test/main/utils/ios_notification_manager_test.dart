import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('notification_interaction_channel');

  void answerTerminatedTap(String? emailId) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == IOSNotificationManager.CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED) {
        return emailId;
      }
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
  }

  group('IOSNotificationManager.wasAppLaunchedByNotification', () {
    test('is true when a tap on a notification started the app', () async {
      answerTerminatedTap('email-1');
      final manager = IOSNotificationManager()..listenClickNotification();
      addTearDown(manager.dispose);

      expect(await manager.wasAppLaunchedByNotification(), isTrue);
    });

    test('should be false on a normal launch', () async {
      answerTerminatedTap('');
      final manager = IOSNotificationManager()..listenClickNotification();
      addTearDown(manager.dispose);

      expect(await manager.wasAppLaunchedByNotification(), isFalse);
    });

    test('should be false before the taps are listened to', () async {
      final manager = IOSNotificationManager();
      addTearDown(manager.dispose);

      expect(await manager.wasAppLaunchedByNotification(), isFalse);
    });
  });
}

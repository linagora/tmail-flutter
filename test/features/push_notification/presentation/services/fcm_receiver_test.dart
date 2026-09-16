import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';

void main() {
  test('refreshes Sentry consent for every background message', () async {
    var initializationCalls = 0;
    var consentRefreshCalls = 0;
    var handledMessages = 0;
    const message = RemoteMessage(messageId: 'message-id');

    Future<void> handle() => handleFirebaseBackgroundMessage(
          message,
          ensureBackgroundInitialized: () async {
            initializationCalls++;
          },
          refreshSentryConfiguration: () async {
            consentRefreshCalls++;
          },
          handleMessage: (_) {
            handledMessages++;
          },
        );

    await handle();
    await handle();

    expect(initializationCalls, 2);
    expect(consentRefreshCalls, 2);
    expect(handledMessages, 2);
  });
}

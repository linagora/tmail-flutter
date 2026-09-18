import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
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
          refreshSentryConfiguration: (_) async {
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

  test('continues handling when Sentry refresh times out', () async {
    var invalidationCalls = 0;
    var handledMessages = 0;
    FcmSentrySetupCancellation? timedOutCancellation;
    final refreshNeverCompletes = Completer<void>();
    const message = RemoteMessage(messageId: 'message-id');

    await handleFirebaseBackgroundMessage(
      message,
      ensureBackgroundInitialized: () async {},
      refreshSentryConfiguration: (_) => refreshNeverCompletes.future,
      invalidateSentryConfiguration: (cancellation) async {
        timedOutCancellation = cancellation;
        cancellation.cancel();
        invalidationCalls++;
      },
      handleMessage: (_) {
        handledMessages++;
      },
      sentryRefreshTimeout: Duration.zero,
    );

    expect(invalidationCalls, 1);
    expect(timedOutCancellation?.isCancelled, isTrue);
    expect(handledMessages, 1);
  });

  test(
    'continues handling when timeout invalidation throws synchronously',
    () async {
      var handledMessages = 0;
      final refreshNeverCompletes = Completer<void>();
      const message = RemoteMessage(messageId: 'message-id');

      await handleFirebaseBackgroundMessage(
        message,
        ensureBackgroundInitialized: () async {},
        refreshSentryConfiguration: (_) => refreshNeverCompletes.future,
        invalidateSentryConfiguration: (_) =>
            throw StateError('invalidation failed'),
        handleMessage: (_) {
          handledMessages++;
        },
        sentryRefreshTimeout: Duration.zero,
      );

      expect(handledMessages, 1);
    },
  );

  test('continues handling when Sentry refresh fails', () async {
    var invalidationCalls = 0;
    var handledMessages = 0;
    const message = RemoteMessage(messageId: 'message-id');

    await handleFirebaseBackgroundMessage(
      message,
      ensureBackgroundInitialized: () async {},
      refreshSentryConfiguration: (_) =>
          throw StateError('refresh failed'),
      invalidateSentryConfiguration: (cancellation) async {
        expect(cancellation.isCancelled, isTrue);
        invalidationCalls++;
      },
      handleMessage: (_) {
        handledMessages++;
      },
    );

    expect(invalidationCalls, 1);
    expect(handledMessages, 1);
  });
}

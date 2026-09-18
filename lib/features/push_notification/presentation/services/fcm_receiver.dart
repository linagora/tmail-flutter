import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';

Future<void>? _backgroundInitFuture;

Future<void> _ensureBackgroundInitialized() {
  return _backgroundInitFuture ??= (() async {
    FcmService.instance.initialStreamController();
    FcmMessageController.instance.initialize();
    await FcmMessageController.instance
        .initialAppConfig()
        .timeout(const Duration(seconds: 10));
  }()).catchError((Object error, StackTrace stackTrace) {
    _backgroundInitFuture = null;
    throw error;
  });
}

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(
  RemoteMessage message, {
  Future<void> Function()? ensureBackgroundInitialized,
  Future<void> Function(FcmSentrySetupCancellation cancellation)? refreshSentryConfiguration,
  Future<void> Function(FcmSentrySetupCancellation cancellation)? invalidateSentryConfiguration,
  void Function(RemoteMessage)? handleMessage,
  Duration sentryRefreshTimeout = const Duration(seconds: 10),
}) async {
  try {
    await (ensureBackgroundInitialized ?? _ensureBackgroundInitialized)();
    await _refreshSentryForBackgroundMessage(
      refreshSentryConfiguration: refreshSentryConfiguration,
      invalidateSentryConfiguration: invalidateSentryConfiguration,
      timeout: sentryRefreshTimeout,
    ).whenComplete(
      () => (handleMessage ??
          FcmService.instance.handleFirebaseBackgroundMessage)(message),
    );
  } catch (e, st) {
    logError(
      'FcmReceiver::handleFirebaseBackgroundMessage: throw exception',
      exception: e,
      stackTrace: st,
    );
  }
}

Future<void> _refreshSentryForBackgroundMessage({
  Future<void> Function(FcmSentrySetupCancellation cancellation)? refreshSentryConfiguration,
  Future<void> Function(FcmSentrySetupCancellation cancellation)? invalidateSentryConfiguration,
  required Duration timeout,
}) async {
  final cancellation = FcmSentrySetupCancellation();
  try {
    await (refreshSentryConfiguration ??
        (cancellation) => FcmMessageController.instance
            .setUpSentryConfiguration(cancellation: cancellation))(
      cancellation,
    ).timeout(timeout);
  } catch (e, st) {
    cancellation.cancel();
    _invalidateSentrySetup(cancellation, invalidateSentryConfiguration);
    _logSentryRefreshFailure(e, st);
  }
}

void _invalidateSentrySetup(
  FcmSentrySetupCancellation cancellation,
  Future<void> Function(FcmSentrySetupCancellation cancellation)? invalidateSentryConfiguration,
) {
  try {
    final invalidation = (invalidateSentryConfiguration ??
        FcmMessageController.instance.invalidateSentrySetup)(cancellation);
    unawaited(invalidation.catchError(_logSentryInvalidationFailure));
  } catch (error, stackTrace) {
    _logSentryInvalidationFailure(error, stackTrace);
  }
}

void _logSentryInvalidationFailure(Object error, StackTrace stackTrace) {
  logError(
    'FcmReceiver::handleFirebaseBackgroundMessage: Failed to invalidate Sentry setup',
    exception: error,
    stackTrace: stackTrace,
  );
}

void _logSentryRefreshFailure(Object error, StackTrace stackTrace) {
  if (error is TimeoutException) {
    logWarning(
      'FcmReceiver::handleFirebaseBackgroundMessage: Sentry refresh timed out: $error\n$stackTrace',
    );
  } else {
    logError(
      'FcmReceiver::handleFirebaseBackgroundMessage: Sentry refresh failed',
      exception: error,
      stackTrace: stackTrace,
    );
  }
}

class FcmReceiver {
  FcmReceiver._internal();

  static final FcmReceiver _instance = FcmReceiver._internal();

  static FcmReceiver get instance => _instance;

  static const int MAX_COUNT_RETRY_TO_GET_FCM_TOKEN = 3;

  Future onInitialFcmListener() async {
    _onBackgroundMessage();

    await _onHandleFcmToken();
  }

  void _onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  Future<String?> _getInitialToken() async {
    for (var attempt = 1; attempt <= MAX_COUNT_RETRY_TO_GET_FCM_TOKEN; attempt++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        log('FcmReceiver::_getInitialToken:token: $token');
        return token;
      } catch (e, st) {
        if (attempt < MAX_COUNT_RETRY_TO_GET_FCM_TOKEN) {
          logWarning('FcmReceiver::_getInitialToken: attempt $attempt failed: $e');
          await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
        } else {
          logError(
            'FcmReceiver::_getInitialToken: all $MAX_COUNT_RETRY_TO_GET_FCM_TOKEN attempts failed',
            exception: e,
            stackTrace: st,
          );
        }
      }
    }
    return null;
  }

  Future _onHandleFcmToken() async {
    var currentToken = await _getInitialToken();
    FcmService.instance.handleToken(currentToken);

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) {
        if (newToken != currentToken) {
          currentToken = newToken;
          FcmService.instance.handleToken(newToken);
        }
      },
      onError: (e, st) {
        logError(
          'FcmReceiver::_onHandleFcmToken:onTokenRefresh:',
          exception: e,
          stackTrace: st,
        );
      },
    );
  }
}

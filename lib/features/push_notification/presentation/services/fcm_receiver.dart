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
    await FcmMessageController.instance
        .setUpSentryConfiguration()
        .timeout(const Duration(seconds: 10));
  }()).catchError((Object error, StackTrace stackTrace) {
    _backgroundInitFuture = null;
    throw error;
  });
}

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  try {
    await _ensureBackgroundInitialized();
    FcmService.instance.handleFirebaseBackgroundMessage(message);
  } catch (e, st) {
    logError(
      'FcmReceiver::handleFirebaseBackgroundMessage: throw exception',
      exception: e,
      stackTrace: st,
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
    try {
      final token = await FirebaseMessaging.instance.getToken();
      log('FcmReceiver::_getInitialToken:token: $token');
      return token;
    } catch (e, st) {
      logError(
        'FcmReceiver::_getInitialToken:',
        exception: e,
        stackTrace: st,
      );
      return null;
    }
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
      }
    );
  }
}
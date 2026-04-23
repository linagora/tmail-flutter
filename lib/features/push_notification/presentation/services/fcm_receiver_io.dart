/// IO-specific FCM receiver (non-web platforms).
/// Checks at runtime whether to use Firebase (mobile) or stub (desktop).

import 'dart:async';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  FcmService.instance.initialStreamController();
  FcmMessageController.instance.initialize();
  FcmService.instance.handleFirebaseBackgroundMessage(message);
}

class FcmReceiver {
  FcmReceiver._internal();

  static final FcmReceiver _instance = FcmReceiver._internal();

  static FcmReceiver get instance => _instance;

  static const int MAX_COUNT_RETRY_TO_GET_FCM_TOKEN = 3;

  static bool get _isMobile => Platform.isIOS || Platform.isAndroid;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _lastToken;

  Future onInitialFcmListener() async {
    if (!_isMobile) {
      log(
        'FcmReceiver::onInitialFcmListener: FCM not supported on desktop, using WebSocket instead',
      );
      return;
    }

    _onBackgroundMessage();
    await _onHandleFcmToken();
  }

  void _onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  Future<String?> _getInitialToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      log('FcmReceiver::_getInitialToken:hasToken: ${token != null}');
      return token;
    } catch (e) {
      logWarning(
        'FcmReceiver::_getInitialToken: TYPE = ${e.runtimeType} | Exception = $e',
      );
      return null;
    }
  }

  Future _onHandleFcmToken() async {
    final token = await _getInitialToken();
    _lastToken = token;
    FcmService.instance.handleToken(token);

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) {
          log('FcmReceiver::_onHandleFcmToken:onTokenRefresh: token changed');
          if (newToken != _lastToken) {
            _lastToken = newToken;
            FcmService.instance.handleToken(newToken);
          }
        });
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _lastToken = null;
  }
}

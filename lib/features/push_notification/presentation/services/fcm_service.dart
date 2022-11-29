
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_controller.dart';

class FcmService {

  static const int durationMessageComing = 2000;

  final StreamController<RemoteMessage> foregroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get foregroundMessageStream => foregroundMessageStreamController.stream;

  final StreamController<RemoteMessage> backgroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get backgroundMessageStream => backgroundMessageStreamController.stream;

  final StreamController<String> fcmTokenStreamController = StreamController<String>.broadcast();
  Stream<String> get fcmTokenStream => fcmTokenStreamController.stream;

  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

  void handleFirebaseForegroundMessage(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseForegroundMessage():messageId: ${newRemoteMessage.messageId}');
    log('FcmService::handleFirebaseForegroundMessage():message: ${newRemoteMessage.data}');
    foregroundMessageStreamController.add(newRemoteMessage);
  }

  void handleFirebaseBackgroundMessage(RemoteMessage newRemoteMessage) {
    FcmController.instance.initialize();
    backgroundMessageStreamController.add(newRemoteMessage);
  }

  void handleRefreshToken(String newToken) {
    fcmTokenStreamController.add(newToken);
  }

  void _closeStream() {
    foregroundMessageStreamController.close();
    backgroundMessageStreamController.close();
  }

  void dispose() {
    _closeStream();
  }
}
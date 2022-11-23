
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:fcm/model/firebase_token.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_controller.dart';

class FcmService {

  static const int durationMessageComing = 2000;

  final StreamController<RemoteMessage> foregroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get foregroundMessageStream => foregroundMessageStreamController.stream;

  final StreamController<RemoteMessage> backgroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get backgroundMessageStream => backgroundMessageStreamController.stream;

  FirebaseToken? currentToken;
  int semaphore = 0;

  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

  void handleFirebaseForegroundMessage(RemoteMessage newRemoteMessage) {
    if (semaphore != 0) {
      return;
    }
    semaphore = 1;
    Future.delayed(const Duration(milliseconds: durationMessageComing)).then((_) => semaphore = 0);

    foregroundMessageStreamController.add(newRemoteMessage);
  }

  void handleFirebaseBackgroundMessage(RemoteMessage newRemoteMessage) {
    FcmController.instance.initialize();
    backgroundMessageStreamController.add(newRemoteMessage);
  }

  void handleFirebaseMessageOpenedApp(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseMessageOpenedApp():newRemoteMessage: ${newRemoteMessage.data}');
  }

  void _closeStream() {
    foregroundMessageStreamController.close();
    backgroundMessageStreamController.close();
  }

  void dispose() {
    _closeStream();
  }
}

import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_controller.dart';

class FcmService {

  static const int durationMessageComing = 2000;
  static const int durationRefreshToken = 2000;

  late StreamController<RemoteMessage> foregroundMessageStreamController;
  Stream<RemoteMessage> get foregroundMessageStream => foregroundMessageStreamController.stream;

  late StreamController<RemoteMessage> backgroundMessageStreamController;
  Stream<RemoteMessage> get backgroundMessageStream => backgroundMessageStreamController.stream;

  late StreamController<String?> fcmTokenStreamController;
  Stream<String?> get fcmTokenStream => fcmTokenStreamController.stream;

  FcmService._internal() {
    foregroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
    backgroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
    fcmTokenStreamController = StreamController<String?>.broadcast();
  }

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

  void handleFirebaseForegroundMessage(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseForegroundMessage():message: ${newRemoteMessage.data}');
    if (!foregroundMessageStreamController.isClosed) {
      foregroundMessageStreamController.add(newRemoteMessage);
    }
  }

  void handleFirebaseBackgroundMessage(RemoteMessage newRemoteMessage) {
    FcmController.instance.initialize();
    if (!backgroundMessageStreamController.isClosed) {
      backgroundMessageStreamController.add(newRemoteMessage);
    }
  }

  void handleGetToken(String? currentToken) async {
    log('FcmService::handleGetToken():currentToken: $currentToken');
    if (fcmTokenStreamController.isClosed) {
      log('FcmService::handleGetToken():fcmTokenStreamController: isClosed');
      fcmTokenStreamController = StreamController<String?>.broadcast();
      await FcmController.instance.listenTokenStream();
    }
    if (!fcmTokenStreamController.isClosed) {
      fcmTokenStreamController.add(currentToken);
    }
  }

  void handleRefreshToken(String? newToken) async {
    log('FcmService::handleRefreshToken():newToken: $newToken');
    if (fcmTokenStreamController.isClosed) {
      log('FcmService::handleRefreshToken():fcmTokenStreamController: isClosed');
      fcmTokenStreamController = StreamController<String?>.broadcast();
      await FcmController.instance.listenTokenStream();
    }
    if (!fcmTokenStreamController.isClosed) {
      fcmTokenStreamController.add(newToken);
    }
  }

  Future<void> recreateStreamController() async {
    if (foregroundMessageStreamController.isClosed) {
      foregroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
      await FcmController.instance.listenForegroundMessageStream();
    }
    if (backgroundMessageStreamController.isClosed) {
      backgroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
      await FcmController.instance.listenBackgroundMessageStream();
    }
    if (fcmTokenStreamController.isClosed) {
      fcmTokenStreamController = StreamController<String?>.broadcast();
      await FcmController.instance.listenTokenStream();
    }
    return Future.value();
  }

  void closeStream() {
    foregroundMessageStreamController.close();
    backgroundMessageStreamController.close();
    fcmTokenStreamController.close();
  }
}
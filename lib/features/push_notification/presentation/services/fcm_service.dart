
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {

  static const int durationMessageComing = 2000;
  static const int durationRefreshToken = 2000;

  StreamController<Map<String, dynamic>>? foregroundMessageStreamController;
  StreamController<Map<String, dynamic>>?  backgroundMessageStreamController;
  StreamController<String?>? fcmTokenStreamController;

  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

  void handleFirebaseForegroundMessage(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseForegroundMessage():data: ${newRemoteMessage.data}');
    if (newRemoteMessage.data.isNotEmpty) {
      foregroundMessageStreamController?.add(newRemoteMessage.data);
    }
  }

  void handleFirebaseBackgroundMessage(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseBackgroundMessage():data: ${newRemoteMessage.data}');
    if (newRemoteMessage.data.isNotEmpty) {
      backgroundMessageStreamController?.add(newRemoteMessage.data);
    }
  }

  void handleToken(String? token) {
    log('FcmService::handleToken():token: $token');
    fcmTokenStreamController?.add(token);
  }

  void initialStreamController() {
    log('FcmService::initialStreamController:');
    foregroundMessageStreamController = StreamController<Map<String, dynamic>>.broadcast();
    backgroundMessageStreamController = StreamController<Map<String, dynamic>>.broadcast();
    fcmTokenStreamController = StreamController<String?>.broadcast();
  }

  void closeStream() {
    foregroundMessageStreamController?.close();
    backgroundMessageStreamController?.close();
    fcmTokenStreamController?.close();

    foregroundMessageStreamController = null;
    backgroundMessageStreamController = null;
    fcmTokenStreamController = null;
  }
}
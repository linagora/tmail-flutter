
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {

  StreamController<Map<String, dynamic>>?  backgroundMessageStreamController;
  StreamController<String?>? fcmTokenStreamController;

  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

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
    backgroundMessageStreamController = StreamController<Map<String, dynamic>>.broadcast();
    fcmTokenStreamController = StreamController<String?>.broadcast();
  }

  void closeStream() {
    backgroundMessageStreamController?.close();
    fcmTokenStreamController?.close();

    backgroundMessageStreamController = null;
    fcmTokenStreamController = null;
  }
}
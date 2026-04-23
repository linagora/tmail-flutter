import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  StreamController<Map<String, dynamic>>? backgroundMessageStreamController;
  StreamController<String?>? fcmTokenStreamController;

  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

  void handleFirebaseBackgroundMessage(RemoteMessage newRemoteMessage) {
    log(
      'FcmService::handleFirebaseBackgroundMessage():dataKeys: ${newRemoteMessage.data.keys.toList()}',
    );
    if (newRemoteMessage.data.isNotEmpty) {
      if (backgroundMessageStreamController?.isClosed == false) {
        backgroundMessageStreamController?.add(newRemoteMessage.data);
      }
    }
  }

  void handleToken(String? token) {
    log('FcmService::handleToken():hasToken: ${token != null}');
    if (fcmTokenStreamController?.isClosed == false) {
      fcmTokenStreamController?.add(token);
    }
  }

  void initialStreamController() {
    log('FcmService::initialStreamController:');
    if (backgroundMessageStreamController?.isClosed != false) {
      backgroundMessageStreamController =
          StreamController<Map<String, dynamic>>.broadcast();
    }
    if (fcmTokenStreamController?.isClosed != false) {
      fcmTokenStreamController = StreamController<String?>.broadcast();
    }
  }

  void closeStream() {
    if (backgroundMessageStreamController?.isClosed == false) {
      backgroundMessageStreamController?.close();
    }
    if (fcmTokenStreamController?.isClosed == false) {
      fcmTokenStreamController?.close();
    }

    backgroundMessageStreamController = null;
    fcmTokenStreamController = null;
  }
}

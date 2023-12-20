
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';

class FcmService {

  static const int durationMessageComing = 2000;
  static const int durationRefreshToken = 2000;

  StreamController<RemoteMessage>? foregroundMessageStreamController;
  StreamController<RemoteMessage>?  backgroundMessageStreamController;
  StreamController<String?>? fcmTokenStreamController;

  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  static FcmService get instance => _instance;

  void handleFirebaseForegroundMessage(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseForegroundMessage():data: ${newRemoteMessage.data}');
    foregroundMessageStreamController?.add(newRemoteMessage);
  }

  void handleFirebaseBackgroundMessage(RemoteMessage newRemoteMessage) {
    log('FcmService::handleFirebaseBackgroundMessage():data: ${newRemoteMessage.data}');
    backgroundMessageStreamController?.add(newRemoteMessage);
  }

  void handleFirebaseMessageOpenedApp(RemoteMessage newRemoteMessage) async {
    log("FcmService::handleFirebaseMessageOpenedApp:");
    await LocalNotificationManager.instance.removeNotificationBadgeForIOS();
  }

  void handleToken(String? token) {
    log('FcmService::handleToken():token: $token');
    fcmTokenStreamController?.add(token);
  }

  void initialStreamController() {
    log('FcmService::initialStreamController:');
    foregroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
    backgroundMessageStreamController = StreamController<RemoteMessage>.broadcast();
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
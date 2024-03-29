
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class FcmService {

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

  void handleOpenEmailFromNotification(String emailId) {
    log('FcmService::handleOpenEmailFromNotification:emailId: $emailId');
    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.home),
      arguments: EmailId(Id(emailId))
    );
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
import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/save_firebase_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await dotenv.load(fileName: 'env.file');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('firebaseMessagingBackgroundHandler: ${message.data}');
}

class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  static get _firebaseMessaging => FirebaseMessaging.instance;

  static Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
  static bool _isFlutterLocalNotificationsInitialized = false;

  static Future<void> initializeNotificationService() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    if (_isFlutterLocalNotificationsInitialized) return;
    final _saveFirebaseCacheInteractor = Get.find<SaveFirebaseCacheInteractor>();
    final token = await _firebaseMessaging.getToken();
    _saveFirebaseCacheInteractor.execute(FirebaseDto(token));
    await _initFirebaseMessaging();
    _isFlutterLocalNotificationsInitialized = true;
  }

  static Future<void> _initFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen(_handleIncomingForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedAppNotification);
  }

  static Future<void> _handleIncomingForegroundNotification(
    RemoteMessage remoteMessage,
  ) async {
    log('firebaseMessagingForegroundHandler: ${remoteMessage.data}');
  }

  static void _handleOpenedAppNotification(RemoteMessage remoteMessage) {}


  static Future<void> deleteToken() async => _firebaseMessaging.deleteToken();
}

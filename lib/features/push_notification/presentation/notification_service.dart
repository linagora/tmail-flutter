import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/save_firebase_cache_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/firebase_options.dart';
import 'notification_strings.dart';

final StreamController<NotificationResponse?> selectNotificationStream =
StreamController<NotificationResponse?>.broadcast();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await dotenv.load(fileName: 'env.file');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.displayPushNotification(message);
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  //handle action
}

void onDidReceiveNotificationResponse(
    NotificationResponse details,
    ) {
  selectNotificationStream.add(details);
}

class NotificationService {
  factory NotificationService() => _instance;

  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  static get _firebaseMessaging => FirebaseMessaging.instance;

  static get _flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  static Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
  static bool _isFlutterLocalNotificationsInitialized = false;

  static Future<void> initializeNotificationService(
    Function(NotificationResponse)? onDidReceiveNotificationResponse,
  ) async {
    if (_isFlutterLocalNotificationsInitialized) return;
    final _saveFirebaseCacheInteractor = Get.find<SaveFirebaseCacheInteractor>();
    final token = await _firebaseMessaging.getToken();
    _saveFirebaseCacheInteractor.execute(FirebaseDto(token));
    await _initFirebaseMessaging();
    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await _requestPermissions();
    await _createNotificationChannels();
    _listenNotificationActionStream();
    _isFlutterLocalNotificationsInitialized = true;
  }

  static Future<void> displayPushNotification(
    RemoteMessage notification,
  ) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        createUniqueId,
        channelName,
        notification.data.toString(),
        pushNotificationDetails,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> _initFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen(_handleIncomingForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedAppNotification);
  }

  static Future<void> _handleIncomingForegroundNotification(
    RemoteMessage remoteMessage,
  ) async {
    await displayPushNotification(remoteMessage);
  }

  static void _handleOpenedAppNotification(RemoteMessage remoteMessage) {}

  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } else {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> _listenNotificationActionStream() async {
    selectNotificationStream.stream
        .listen((event) => event)
        .onData((data) async {
      switch (data?.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          break;
        case NotificationResponseType.selectedNotificationAction:
          break;
        default:
      }
    });
  }

  static Future<void> _createNotificationChannels() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> deleteToken() async => _firebaseMessaging.deleteToken();
}

int get createUniqueId =>
    DateTime.now().millisecondsSinceEpoch.remainder(100000);

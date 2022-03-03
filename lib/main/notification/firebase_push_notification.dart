import 'dart:io';

import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushNotification {
  final FirebaseMessaging _firebaseMessaging;

  FirebasePushNotification(this._firebaseMessaging) {
    handleForegroundNotification();
    handleBackgroundNotification();
    getToken();
  }

  void requestPermission() async {
    if (Platform.isIOS) await _firebaseMessaging.requestPermission();
  }

  void handleForegroundNotification() {
    FirebaseMessaging.onMessage.listen((message) {
      log('FirebasePushNotification::handleForegroundNotification(): Message title: ${message.notification?.title}');
      log('FirebasePushNotification::handleForegroundNotification(): Message data: ${message.notification?.body}');
    });
  }

  void handleBackgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('FirebasePushNotification::handleBackgroundNotification(): Message clicked!');
    });
  }

  void getToken() {
    _firebaseMessaging.getToken().then((token) {
      log('FirebasePushNotification::getToken(): $token');
    });
  }
}
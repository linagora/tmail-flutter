import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushNotification {
  final FirebaseMessaging _firebaseMessaging;

  FirebasePushNotification(this._firebaseMessaging) {
    handleForegroundNotification();
    handleBackgroundNotification();
  }

  void requestPermission() async {
    if (Platform.isIOS) await _firebaseMessaging.requestPermission();
  }

  void handleForegroundNotification() {
    FirebaseMessaging.onMessage.listen((message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void handleBackgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
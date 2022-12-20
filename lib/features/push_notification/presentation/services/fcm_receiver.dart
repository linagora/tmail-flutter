import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  log('FcmReceiver::handleFirebaseBackgroundMessage():messageId: ${message.messageId}');
  log('FcmReceiver::handleFirebaseBackgroundMessage(): ${message.data}');
// Success
//   try {
//     var request = await Dio().post('https://jmap.linagora.com/jmap',
//         data: {
//           "using": ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
//           "methodCalls": [
//             [
//               "Email/query",
//               {
//                 "accountId":
//                     "2871cff2a1fdca653db3eb30876ea938778bb39cb0dc525ac5fe101ce8da9432",
//                 "filter": {"from": "ttnn"},
//                 "sort": [
//                   {"isAscending": false, "property": "receivedAt"}
//                 ],
//                 "limit": 20
//               },
//               "c0"
//             ],
//             [
//               "Email/get",
//               {
//                 "accountId":
//                     "2871cff2a1fdca653db3eb30876ea938778bb39cb0dc525ac5fe101ce8da9432",
//                 "#ids": {
//                   "resultOf": "c0",
//                   "name": "Email/query",
//                   "path": "/ids/*"
//                 },
//                 "properties": [
//                   "id",
//                   "subject",
//                   "from",
//                   "to",
//                   "cc",
//                   "bcc",
//                   "keywords",
//                   "size",
//                   "receivedAt",
//                   "sentAt",
//                   "preview",
//                   "hasAttachment",
//                   "replyTo",
//                   "mailboxIds"
//                 ]
//               },
//               "c1"
//             ]
//           ]
//         },
//         options: Options(headers: {
//           'accept': 'application/json;jmapVersion=rfc-8621',
//           'content-type': 'application/json',
//           'Authorization': 'Basic dG1uZ3V5ZW5AbGluYWdvcmEuY29tOk1hbmhAMTk5Njcy'
//         }));
//     if (request.statusCode == 200) {
//       print(request.data);
//     }
//   } catch (e) {
//     print(e);
//   }
  FcmService.instance.handleFirebaseBackgroundMessage(message);
}

class FcmReceiver {
  FcmReceiver._internal();

  static final FcmReceiver _instance = FcmReceiver._internal();

  static FcmReceiver get instance => _instance;

  void onForegroundMessage() {
    FirebaseMessaging.onMessage
        .listen(FcmService.instance.handleFirebaseForegroundMessage);
  }

  void onBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
  }

  void getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb
              ? dotenv.get('FIREBASE_WEB_VAPID_PUBLIC_KEY', fallback: '')
              : null);
      log('FcmReceiver::onFcmToken():token: $token');
      FcmService.instance.handleRefreshToken(token);
    } catch (e) {
      log('FcmReceiver::onFcmToken():exception: $e');
      throw NotLoadedFCMTokenException();
    }
  }

  void onRefreshFcmToken() {
    FirebaseMessaging.instance.onTokenRefresh
        .listen(FcmService.instance.handleRefreshToken);
  }
}

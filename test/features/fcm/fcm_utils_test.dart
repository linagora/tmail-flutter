
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:jmap_dart_client/jmap/push/type_state.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';

void main() {

  final expectStateChange1 = StateChange(
    'StateChange',
    {
      AccountId(Id('a3123')): TypeState({
        'Email': 'd35ecb040aab',
        'EmailDelivery': '428d565f2440',
        'CalendarEvent': '87accfac587a'
      }),
      AccountId(Id('a43461d')): TypeState({
        'Mailbox': '0af7a512ce70',
        'CalendarEvent': '7a4297cecd76'
      })
    }
  );

  final expectStateChange2 = StateChange(
    'StateChange',
    {
      AccountId(Id('a3123')): TypeState({
        'EmailDelivery': '428d565f2440',
        'CalendarEvent': '87accfac587a'
      }),
      AccountId(Id('a43461d')): TypeState({
        'Mailbox': '0af7a512ce70',
        'CalendarEvent': '7a4297cecd76'
      })
    }
  );

  group('decodeFirebaseDataMessageToStateChange test', () {
    test('should return StateChange when parse from firebase data message with key/value is not empty', () {
      
      final dataMessage = {
        "data": {
          "a3123:Email": "d35ecb040aab",
          "a3123:EmailDelivery": "428d565f2440",
          "a3123:CalendarEvent": "87accfac587a",
          "a43461d:Mailbox": "0af7a512ce70",
          "a43461d:CalendarEvent": "7a4297cecd76"
        },
        "token": "fcm-client-token"
      };

      final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(dataMessage);
      
      expect(stateChange, equals(expectStateChange1));
    });

    test('should return StateChange when parse from firebase data message with value is empty', () {

      final dataMessage = {
        "data": {
          "a3123:Email": "",
          "a3123:EmailDelivery": "428d565f2440",
          "a3123:CalendarEvent": "87accfac587a",
          "a43461d:Mailbox": "0af7a512ce70",
          "a43461d:CalendarEvent": "7a4297cecd76"
        },
        "token": "fcm-client-token"
      };

      final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(dataMessage);

      expect(stateChange, equals(expectStateChange2));
    });

    test('should return StateChange when parse from firebase data message with key is empty', () {

      final dataMessage = {
        "data": {
          "": "d35ecb040aab",
          "a3123:EmailDelivery": "428d565f2440",
          "a3123:CalendarEvent": "87accfac587a",
          "a43461d:Mailbox": "0af7a512ce70",
          "a43461d:CalendarEvent": "7a4297cecd76"
        },
        "token": "fcm-client-token"
      };

      final stateChange = FcmUtils.instance.convertFirebaseDataMessageToStateChange(dataMessage);

      expect(stateChange, equals(expectStateChange2));
    });
  });
}
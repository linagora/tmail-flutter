import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/notification/notification_payload.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';

void main() {
  group('IOSNotificationManager.notificationTapOf', () {
    test('reads an email id sent alone', () {
      expect(
        IOSNotificationManager.notificationTapOf('e-1'),
        NotificationPayload(emailId: EmailId(Id('e-1'))),
      );
    });

    test('reads the email id and the account id of a delegated mailbox', () {
      expect(
        IOSNotificationManager.notificationTapOf({'email_id': 'e-1', 'account_id': 'bob-account-id'}),
        NotificationPayload(emailId: EmailId(Id('e-1')), accountId: AccountId(Id('bob-account-id'))),
      );
    });

    test('reads my own account from a map without an account id', () {
      expect(
        IOSNotificationManager.notificationTapOf({'email_id': 'e-1', 'account_id': ''}),
        NotificationPayload(emailId: EmailId(Id('e-1'))),
      );
    });

    test('SHOULD NOT read a tap without an email id', () {
      expect(IOSNotificationManager.notificationTapOf(null), isNull);
      expect(IOSNotificationManager.notificationTapOf(''), isNull);
      expect(IOSNotificationManager.notificationTapOf({'account_id': 'bob-account-id'}), isNull);
      expect(IOSNotificationManager.notificationTapOf({'email_id': 42}), isNull);
    });
  });

  group('IOSNotificationManager.takePendingTap', () {
    final tap = NotificationPayload(emailId: EmailId(Id('e-1')), accountId: AccountId(Id('bob-account-id')));

    test('returns the pending tap once', () {
      final manager = IOSNotificationManager()..setPendingCurrentEmailId(tap);

      expect(manager.takePendingTap(), tap);
      expect(manager.takePendingTap(), isNull);
      expect(manager.pendingCurrentEmailIdInNotification.value, isNull);
    });

    test('SHOULD NOT return anything without a pending tap', () {
      expect(IOSNotificationManager().takePendingTap(), isNull);
    });
  });
}

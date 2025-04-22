import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

void main() {
  group('Validation email address test', () {

    final emailsValid = [
      EmailAddress("userName", "alice@localhost"),
      EmailAddress("userName", "bob@localhost"),
      EmailAddress("userName", "123@localhost"),
      EmailAddress("userName", "alic.2312e@localhost"),
      EmailAddress("userName", "alice_linagora@localhost")
    ];

    final emailsInvalid = [
      EmailAddress("userName", "localhost"),
      EmailAddress("userName", "bob@local"),
      EmailAddress("userName", "123@domain"),
      EmailAddress("userName", "alic.2312e@"),
      EmailAddress("userName", "a,.2312lic.2312e@")
    ];

    test('Valid localhost email addresses', () {
      for (final email in emailsValid) {
        expect(AppUtils.isEmailLocalhost(email.emailAddress), equals(true));
      }
    });

    test('Invalid localhost email addresses', () {
      for (final email in emailsInvalid) {
        expect(AppUtils.isEmailLocalhost(email.emailAddress), equals(false));
      }
    });
  });
}
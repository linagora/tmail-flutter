import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('EmailUtils', () {
    test('isSameDomain should return true when email is from the same domain as server', () {
      String emailAddress = 'user@example.com';
      String serverDomain = 'example.com';

      bool result = EmailUtils.isSameDomain(emailAddress: emailAddress, serverDomain: serverDomain);

      expect(result, true);
    });

    test('isSameDomain should return false when email is not from the same domain as server', () {
      String emailAddress = 'user@example.com';
      String serverDomain = 'example2.com';

      bool result = EmailUtils.isSameDomain(emailAddress: emailAddress, serverDomain: serverDomain);

      expect(result, false);
    });

    test('isSameDomain should return false when email is invalid', () {
      String emailAddress = 'invalid_email';
      String serverDomain = 'example.com';

      bool result = EmailUtils.isSameDomain(emailAddress: emailAddress, serverDomain: serverDomain);

      expect(result, false);
    });
  });
}
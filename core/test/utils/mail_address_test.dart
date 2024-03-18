import 'package:core/domain/exceptions/address_exception.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MailAddress test', () {
    test('validate method should be return MailAddress when address valid', () {
      String validAddress = 'user@example.com';
      MailAddress mailAddress = MailAddress.validate(validAddress);
      expect(mailAddress.localPart, equals('user'));
      expect(mailAddress.domain.name(), equals('example.com'));
    });

    test('validate method should be throw AddressException when address missing @', () {
      String invalidAddress = 'userexample.com';
      expect(
        () => MailAddress.validate(invalidAddress),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'Did not find @ between local-part and domain at position 16 in "userexample.com"')
        )
      );
    });

    test('validate method should be throw AddressException when address empty local-part', () {
      String invalidAddress = '@example.com';
      expect(
        () => MailAddress.validate(invalidAddress),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'No local-part (user account) found at position 1  in "@example.com"')
        )
      );
    });

    test('validate method should be throw AddressException when address empty domain', () {
      String invalidAddress = 'user@';
      expect(
        () => MailAddress.validate(invalidAddress),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'No domain found at position 6 in "user@"')
        )
      );
    });

    test('validate method should be throw AddressException when address with a hyphen "-"', () {
      String invalidAddress = 'user@-example.com';
      expect(
        () => MailAddress.validate(invalidAddress),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'Domain name cannot begin or end with a hyphen "-" at position 14 in "user@-example.com"')
        )
      );
    });
  });
}
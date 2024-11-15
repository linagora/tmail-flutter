import 'package:core/domain/exceptions/address_exception.dart';
import 'package:core/utils/mail/domain.dart';
import 'package:core/utils/mail/mail_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String GOOD_LOCAL_PART = "\"quoted@local part\"";
  const String GOOD_QUOTED_LOCAL_PART = "\"quoted@local part\"@james.apache.org";
  const String GOOD_ADDRESS = "server-dev@james.apache.org";
  final Domain GOOD_DOMAIN = Domain.of("james.apache.org");

  final List<String> goodAddresses = [
    GOOD_ADDRESS,
    GOOD_QUOTED_LOCAL_PART,
    "server-dev@james-apache.org",
    "server-dev@[127.0.0.1]",
    "server.dev@james.apache.org",
    "\\.server-dev@james.apache.org",
    "Abc@10.42.0.1",
    "Abc.123@example.com",
    "user+mailbox/department=shipping@example.com",
    "user+mailbox@example.com",
    "user+folder@james.apache.org",
    "user+my folder@domain.com",
    "user+Dossier d'été@domain.com",
    "\"Abc@def\"@example.com",
    "\"Fred Bloggs\"@example.com",
    "\"Joe.\\Blow\"@example.com",
    "!#\$%&'*+-/=?^_`.{|}~@example.com"
  ];

  final List<String> badAddresses = [
    "",
    "server-dev",
    "server-dev@",
    "[]",
    "server-dev@[]",
    "server-dev@#",
    "quoted local-part@james.apache.org",
    "quoted@local-part@james.apache.org",
    "local-part.@james.apache.org",
    ".local-part@james.apache.org",
    "local-part@.james.apache.org",
    "local-part@james.apache.org.",
    "local-part@james.apache..org",
    "server-dev@-james.apache.org",
    "server-dev@james.apache.org-",
    "server-dev@#james.apache.org",
    "server-dev@#123james.apache.org",
    "server-dev@#-123.james.apache.org",
    "server-dev@james. apache.org",
    "server-dev@james\\.apache.org",
    "server-dev@[300.0.0.1]",
    "server-dev@[127.0.1]",
    "server-dev@[0127.0.0.1]",
    "server-dev@[127.0.1.1a]",
    "server-dev@[127\\.0.1.1]",
    "server-dev@#123",
    "server-dev@#123.apache.org",
    "server-dev@[127.0.1.1.1]",
    "server-dev@[127.0.1.-1]",
    "user+@domain.com",
    "user+ @domain.com",
    "user+#folder@domain.com",
    "user+test-_.!~*'() @domain.com",
    "\"a..b\"@domain.com", // jakarta.mail is unable to handle this so we better reject it
    "server-dev\\.@james.apache.org", // jakarta.mail is unable to handle this so we better reject it
    "a..b@domain.com",
    // According to wikipedia these addresses are valid but as jakarta.mail is unable
    // to work with them we shall rather reject them (note that this is not breaking retro-compatibility)
    "Loïc.Accentué@voilà.fr8",
    "pelé@exemple.com",
    "δοκιμή@παράδειγμα.δοκιμή",
    "我買@屋企.香港",
    "二ノ宮@黒川.日本",
    "медведь@с-балалайкой.рф",
    "संपर्क@डाटामेल.भारत"
  ];

  group('MailAddress simple test', () {
    test('MailAddress.validateAddress() should be return MailAddress when address valid', () {
      MailAddress mailAddress = MailAddress.validateAddress('user@example.com');
      expect(mailAddress.localPart, equals('user'));
      expect(mailAddress.domain.name(), equals('example.com'));
    });

    test('MailAddress.validateAddress() should be throw AddressException when address missing @', () {
      expect(
        () => MailAddress.validateAddress('userexample.com'),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'Did not find @ between local-part and domain at position 16 in "userexample.com"')
        )
      );
    });

    test('MailAddress.validateAddress() should be throw AddressException when address empty local-part', () {
      expect(
        () => MailAddress.validateAddress('@example.com'),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'No local-part (user account) found at position 1  in "@example.com"')
        )
      );
    });

    test('MailAddress.validateAddress() should be throw AddressException when address empty domain', () {
      expect(
        () => MailAddress.validateAddress('user@'),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'No domain found at position 6 in "user@"')
        )
      );
    });

    test('MailAddress.validateAddress() should be throw AddressException when address with a hyphen "-"', () {
      expect(
        () => MailAddress.validateAddress('user@-example.com'),
        throwsA(isA<AddressException>().having(
          (e) => e.message,
          'message',
          'Domain name cannot begin or end with a hyphen "-" at position 14 in "user@-example.com"')
        )
      );
    });
  });

  group('MailAddress advanced test', () {
    group('MailAddress.validateAddress() should not throw any exceptions with the list of good address', () {
      for (var arg in goodAddresses) {
        test(arg, () {
          expect(() => MailAddress.validateAddress(arg), returnsNormally);
        });
      }
    });

    group('MailAddress.validateAddress() should throw an AddressException with a list of bad address', () {
      for (var arg in badAddresses) {
        test(arg, () {
          expect(() => MailAddress.validateAddress(arg), throwsA(const TypeMatcher<AddressException>()));
        });
      }
    });

    test('MailAddress.validateLocalPartAndDomain() should not throw any exceptions with good address have LocalPart and Domain', () {
      expect(() => MailAddress.validateLocalPartAndDomain(localPart: 'local-part', domain: 'domain'), returnsNormally);
    });

    test('MailAddress.validateLocalPartAndDomain() should throw an AddressException with bad address have LocalPart and Domain', () {
      expect(() => MailAddress.validateLocalPartAndDomain(localPart: 'local-part', domain: '-domain'), throwsA(const TypeMatcher<AddressException>()));
    });

    test('MailAddress.validateAddress() should not throw any exceptions with mail address is GOOD_QUOTED_LOCAL_PART', () {
      expect(() => MailAddress.validateAddress(GOOD_QUOTED_LOCAL_PART), returnsNormally);
    });

    test('MailAddress.getDomain() should return GOOD_DOMAIN with address is GOOD_ADDRESS', () {
      final mailAddress = MailAddress.validateAddress(GOOD_ADDRESS);
      expect(mailAddress.getDomain(), equals(GOOD_DOMAIN));
    });

    test('MailAddress.getLocalPart() should return GOOD_LOCAL_PART with address is GOOD_QUOTED_LOCAL_PART', () {
      final mailAddress = MailAddress.validateAddress(GOOD_QUOTED_LOCAL_PART);
      expect(mailAddress.getLocalPart(), equals(GOOD_LOCAL_PART));
    });

    test('MailAddress.toString() should return GOOD_ADDRESS with address is GOOD_ADDRESS', () {
      final mailAddress = MailAddress.validateAddress(GOOD_ADDRESS);
      expect(mailAddress.toString(), equals(GOOD_ADDRESS));
    });

    test('MailAddress.encodeLocalPartDetails() should work with characters to encode', () {
      final mailAddress = MailAddress.validateAddress("user+my folder@domain.com");
      expect(mailAddress.asEncodedString(), equals("user+my%20folder@domain.com"));
    });

    test('MailAddress.encodeLocalPartDetails() should work with many characters to encode', () {
      final mailAddress = MailAddress.validateAddress("user+Dossier d'été@domain.com");
      expect(mailAddress.asEncodedString(), equals("user+Dossier%20d%27%C3%A9t%C3%A9@domain.com"));
    });

    test('MailAddress.encodeLocalPartDetails() should encode the rights characters', () {
      final mailAddress = MailAddress.validateAddress("user+test-_.!~'() @domain.com");
      expect(mailAddress.asEncodedString(), equals("user+test-_.%21~%27%28%29%20@domain.com"));
    });

    test('getLocalPartDetails() should work', () {
      final mailAddress = MailAddress.validateAddress("user+details@domain.com");
      expect(mailAddress.getLocalPartDetails(), equals("details"));
    });

    test('getLocalPartWithoutDetails() should work', () {
      final mailAddress = MailAddress.validateAddress("user+details@domain.com");
      expect(mailAddress.getLocalPartWithoutDetails(), equals("user"));
    });

    test('stripDetails() should work', () {
      final mailAddress = MailAddress.validateAddress("user+details@domain.com");
      expect(mailAddress.stripDetails().asString(), equals("user@domain.com"));
    });

    test('stripDetails() should work with encoded local part', () {
      final mailAddress = MailAddress.validateAddress("user+Dossier%20d%27%C3%A9t%C3%A9@domain.com");
      expect(mailAddress.stripDetails().asString(), equals("user@domain.com"));
    });

    test('stripDetails() should work when local part needs encoding', () {
      final mailAddress = MailAddress.validateAddress("user+super folder@domain.com");
      expect(mailAddress.stripDetails().asString(), equals("user@domain.com"));
    });

  });
}
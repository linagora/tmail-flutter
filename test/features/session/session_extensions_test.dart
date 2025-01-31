import 'package:contact/contact_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

import '../../fixtures/account_fixtures.dart';

void main() {
  group('getMinInputLengthAutocomplete::test', () {
    test('SHOULD return minInputLength WHEN AutocompleteCapability is available', () {
      // Arrange
      final autocompleteCapability = AutocompleteCapability(minInputLength: UnsignedInt(3));
      final session = Session(
        {
          tmailContactCapabilityIdentifier: autocompleteCapability
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              tmailContactCapabilityIdentifier: autocompleteCapability
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''));

      // Act
      final result = session.getMinInputLengthAutocomplete(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, autocompleteCapability.minInputLength);
    });

    test('SHOULD return null WHEN AutocompleteCapability is not available', () {
      // Arrange
      final session = Session(
        {
          tmailContactCapabilityIdentifier: EmptyCapability()
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              tmailContactCapabilityIdentifier: EmptyCapability()
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''));

      // Act
      final result = session.getMinInputLengthAutocomplete(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });

    test('SHOULD return null WHEN autocomplete capability is not supported', () {
      // Arrange
      final session = Session(
        {},
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {},
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''));

      // Act
      final result = session.getMinInputLengthAutocomplete(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });
  });

  group('getContactSupportCapability::test', () {
    test('SHOULD return ContactSupportCapability WHEN ContactSupportCapability is available', () {
      // Arrange
      final contactSupportCapability = ContactSupportCapability(
        supportMailAddress: 'contact.support@example.com',
        httpLink: 'https://contact.support',
      );
      final session = Session(
          {
            SessionExtensions.linagoraContactSupportCapability: contactSupportCapability
          },
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
                SessionExtensions.linagoraContactSupportCapability: contactSupportCapability
              },
            )
          },
          {},
          UserName(''),
          Uri(),
          Uri(),
          Uri(),
          Uri(),
          State(''),
      );

      // Act
      final result = session.getContactSupportCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result?.supportMailAddress, equals(contactSupportCapability.supportMailAddress));
      expect(result?.httpLink, equals(contactSupportCapability.httpLink));
    });

    test('SHOULD return ContactSupportCapability WHEN DefaultCapability is available ', () {
      // Arrange
      const supportMailAddress = 'contact.support@example.com';
      const httpLink = 'https://contact.support';
      final defaultCapability = DefaultCapability({
        'supportMailAddress': supportMailAddress,
        'httpLink': httpLink,
      });
      final session = Session(
        {
          SessionExtensions.linagoraContactSupportCapability: defaultCapability
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              SessionExtensions.linagoraContactSupportCapability: defaultCapability
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''),
      );

      // Act
      final result = session.getContactSupportCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result?.supportMailAddress, equals(supportMailAddress));
      expect(result?.httpLink, equals(httpLink));
    });

    test('SHOULD return null WHEN ContactSupportCapability is not available (EmptyCapability)', () {
      // Arrange
      final session = Session(
          {
            SessionExtensions.linagoraContactSupportCapability: EmptyCapability()
          },
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
                SessionExtensions.linagoraContactSupportCapability: EmptyCapability()
              },
            )
          },
          {},
          UserName(''),
          Uri(),
          Uri(),
          Uri(),
          Uri(),
          State(''),
      );

      // Act
      final result = session.getContactSupportCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });

    test('SHOULD return null WHEN ContactSupportCapability is not available (empty ContactSupportCapability)', () {
      // Arrange
      final session = Session(
        {
          SessionExtensions.linagoraContactSupportCapability: ContactSupportCapability()
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              SessionExtensions.linagoraContactSupportCapability: EmptyCapability()
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''),
      );

      // Act
      final result = session.getContactSupportCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });

    test('SHOULD return null WHEN ContactSupportCapability is not available (empty DefaultCapability)', () {
      // Arrange
      final session = Session(
        {
          SessionExtensions.linagoraContactSupportCapability: DefaultCapability({})
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              SessionExtensions.linagoraContactSupportCapability: EmptyCapability()
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''),
      );

      // Act
      final result = session.getContactSupportCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });

    test('SHOULD return null WHEN ContactSupportCapability is not supported', () {
      // Arrange
      final session = Session(
          {},
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {},
            )
          },
          {},
          UserName(''),
          Uri(),
          Uri(),
          Uri(),
          Uri(),
          State(''),
      );

      // Act
      final result = session.getContactSupportCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });
  });
}

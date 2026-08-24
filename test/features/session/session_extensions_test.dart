import 'package:contact/contact_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/download_all/download_all_capability.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:model/upload/upload_from_url_capability.dart';
import 'package:tmail_ui_user/features/home/data/extensions/session_hive_obj_extension.dart';
import 'package:tmail_ui_user/features/home/domain/converter/capability_properties_converter.dart';
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

    test('SHOULD return null WHEN ContactSupportCapability is not available', () {
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

  group('isDownloadAllSupported::test', () {
    test('SHOULD return false WHEN AccountId is null', () {
      // Arrange
      final session = Session(
          {},
          {},
          {},
          UserName(''),
          Uri(),
          Uri(),
          Uri(),
          Uri(),
          State(''),
      );

      // Act
      final result = session.isDownloadAllSupported(null);

      // Assert
      expect(result, isFalse);
    });

    test('SHOULD return false WHEN isSupported is false', () {
      // Arrange
      final session = Session(
          {},
          {},
          {},
          UserName(''),
          Uri(),
          Uri(),
          Uri(),
          Uri(),
          State(''),
      );

      // Act
      final result = session.isDownloadAllSupported(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isFalse);
    });

    test('SHOULD return false WHEN isSupported is true but endpoint is null', () {
      // Arrange
      final session = Session(
          {},
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
                SessionExtensions.linagoraDownloadAllCapability: DownloadAllCapability()
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
      final result = session.isDownloadAllSupported(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isFalse);
    });

    test('SHOULD return false WHEN isSupported is true but endpoint is empty', () {
      // Arrange
      final session = Session(
          {},
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
                SessionExtensions.linagoraDownloadAllCapability: DownloadAllCapability(endpoint: '')
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
      final result = session.isDownloadAllSupported(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isFalse);
    });

    test('SHOULD return true WHEN isSupported is true and endpoint is not empty', () {
      // Arrange
      final session = Session(
          {},
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
              SessionExtensions.linagoraDownloadAllCapability: DownloadAllCapability(
                endpoint: 'https://example.com')
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
      final result = session.isDownloadAllSupported(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isTrue);
    });
  });

  group('getDownloadAllCapability::test', () {
    test('SHOULD return DownloadAllCapability WHEN DownloadAllCapability is available', () {
      // Arrange
      final session = Session(
          {},
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
                SessionExtensions.linagoraDownloadAllCapability: DownloadAllCapability()
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
      final result = session.getDownloadAllCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNotNull);
    });
    test('SHOULD return null WHEN DownloadAllCapability is not available', () {
      // Arrange
      final session = Session(
          {},
          {
            AccountFixtures.aliceAccountId: Account(
              AccountName('Alice'),
              true,
              false,
              {
                SessionExtensions.linagoraDownloadAllCapability: EmptyCapability()
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
      final result = session.getDownloadAllCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });
    test('SHOULD return null WHEN DownloadAllCapability is not supported', () {
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
      final result = session.getDownloadAllCapability(AccountFixtures.aliceAccountId);

      // Assert
      expect(result, isNull);
    });
  });

  group('uploadFromUrlCapability::test', () {
    Session sessionWith(Map<CapabilityIdentifier, CapabilityProperties> accountCapabilities) => Session(
      {},
      {
        AccountFixtures.aliceAccountId: Account(
          AccountName('Alice'),
          true,
          false,
          accountCapabilities,
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

    final capabilityWithTemplate = UploadFromUrlCapability(
      uploadUrl: Uri.parse('https://mail.example.com/upload-from-url/{accountId}'),
    );

    test('SHOULD not be supported WHEN AccountId is null', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: capabilityWithTemplate,
      });

      expect(session.isUploadFromUrlSupported(null, jmapUrl: 'https://mail.example.com'), isFalse);
      expect(session.getUploadFromUrlUri(null, jmapUrl: 'https://mail.example.com'), isNull);
    });

    test('SHOULD not be supported WHEN the capability is absent', () {
      final session = sessionWith({});

      expect(session.isUploadFromUrlSupported(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com'), isFalse);
      expect(session.getUploadFromUrlUri(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com'), isNull);
    });

    test('SHOULD not be supported WHEN the capability advertises no uploadUrl', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: UploadFromUrlCapability(),
      });

      expect(session.isUploadFromUrlSupported(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com'), isFalse);
      expect(session.getUploadFromUrlUri(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com'), isNull);
    });

    test('SHOULD be supported AND expand the accountId template WHEN the capability advertises an absolute url', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: capabilityWithTemplate,
      });

      expect(session.isUploadFromUrlSupported(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com'), isTrue);
      expect(
        session.getUploadFromUrlUri(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com').toString(),
        'https://mail.example.com/upload-from-url/${AccountFixtures.aliceAccountId.id.value}',
      );
    });

    test('SHOULD qualify a relative advertised url against the jmapUrl', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: UploadFromUrlCapability(
          uploadUrl: Uri.parse('/upload-from-url/{accountId}'),
        ),
      });

      expect(
        session.getUploadFromUrlUri(
          AccountFixtures.aliceAccountId,
          jmapUrl: 'https://mail.example.com',
        ).toString(),
        'https://mail.example.com/upload-from-url/${AccountFixtures.aliceAccountId.id.value}',
      );
    });

    test('SHOULD preserve the query string AND an encoded path segment WHEN expanding the template', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: UploadFromUrlCapability(
          uploadUrl: Uri.parse('https://mail.example.com/upload-from-url%2Fv2/{accountId}?required=true'),
        ),
      });

      expect(
        session.getUploadFromUrlUri(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com').toString(),
        'https://mail.example.com/upload-from-url%2Fv2/${AccountFixtures.aliceAccountId.id.value}?required=true',
      );
    });

    test('SHOULD qualify a relative advertised url without a leading slash against a jmapUrl with a path', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: UploadFromUrlCapability(
          uploadUrl: Uri.parse('upload-from-url/{accountId}'),
        ),
      });

      expect(
        session.getUploadFromUrlUri(
          AccountFixtures.aliceAccountId,
          jmapUrl: 'https://host/jmap/api',
        ).toString(),
        'https://host/jmap/api/upload-from-url/${AccountFixtures.aliceAccountId.id.value}',
      );
    });

    test('SHOULD return null WHEN the advertised url is scheme-relative', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: UploadFromUrlCapability(
          uploadUrl: Uri.parse('//mail.example.com/upload-from-url/{accountId}'),
        ),
      });

      expect(
        session.getUploadFromUrlUri(
          AccountFixtures.aliceAccountId,
          jmapUrl: 'https://mail.example.com',
        ),
        isNull,
      );
    });

    test('SHOULD expand the accountId template WHEN it is located in the query string', () {
      final session = sessionWith({
        SessionExtensions.linagoraUploadFromUrlCapability: UploadFromUrlCapability(
          uploadUrl: Uri.parse('https://mail.example.com/upload-from-url?account={accountId}'),
        ),
      });

      expect(
        session.getUploadFromUrlUri(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com').toString(),
        'https://mail.example.com/upload-from-url?account=${AccountFixtures.aliceAccountId.id.value}',
      );
    });

    test('SHOULD keep uploadUrl after hive persist and restore', () {
      final session = Session(
        {
          SessionExtensions.linagoraUploadFromUrlCapability: capabilityWithTemplate,
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              SessionExtensions.linagoraUploadFromUrlCapability: capabilityWithTemplate,
            },
          )
        },
        {},
        UserName('alice@example.com'),
        Uri.parse('https://mail.example.com/jmap'),
        Uri.parse('https://mail.example.com/download'),
        Uri.parse('https://mail.example.com/upload'),
        Uri.parse('https://mail.example.com/eventSource'),
        State('1'),
      );

      final restored = session.toHiveObj().toSession();

      expect(
        restored.getUploadFromUrlUri(AccountFixtures.aliceAccountId, jmapUrl: 'https://mail.example.com').toString(),
        'https://mail.example.com/upload-from-url/${AccountFixtures.aliceAccountId.id.value}',
      );
    });

    test('SHOULD serialize UploadFromUrlCapability uploadUrl', () {
      expect(
        CapabilityPropertiesConverter().toJson(capabilityWithTemplate),
        {
          'uploadUrl': 'https://mail.example.com/upload-from-url/%7BaccountId%7D',
        },
      );
    });
  });
}

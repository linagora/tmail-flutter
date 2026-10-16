import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/saas/saas_account_capability.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';

void main() {
  final accountId = AccountFixtures.aliceAccountId;

  group('SessionExtensions::isMailDnsConfigurationValidated', () {
    test('SHOULD be true WHEN the session has no SaaS capability', () {
      expect(
        SessionFixtures.aliceSession.isMailDnsConfigurationValidated(accountId),
        isTrue,
      );
    });

    test('SHOULD be true WHEN the SaaS capability says validated', () {
      expect(
        SessionFixtures.getAliceSessionWithSaaSCapability(
          mailDnsConfigurationValidated: true,
        ).isMailDnsConfigurationValidated(accountId),
        isTrue,
      );
    });

    test('SHOULD be false WHEN the SaaS capability says not validated', () {
      expect(
        SessionFixtures.getAliceSessionWithSaaSCapability(
          mailDnsConfigurationValidated: false,
        ).isMailDnsConfigurationValidated(accountId),
        isFalse,
      );
    });

    test('SHOULD be true WHEN the SaaS capability belongs to another account', () {
      expect(
        SessionFixtures.getAliceSessionWithSaaSCapability(
          mailDnsConfigurationValidated: false,
        ).isMailDnsConfigurationValidated(AccountId(Id('bob'))),
        isTrue,
      );
    });
  });

  group('SaaSAccountCapability::mailDnsConfigurationValidated', () {
    test('SHOULD default to true WHEN the server omits the field', () {
      final capability = SaaSAccountCapability.deserialize({
        'isPaying': true,
        'canUpgrade': false,
      });

      expect(capability.mailDnsConfigurationValidated, isTrue);
    });

    test('SHOULD be read WHEN the server sends it', () {
      final capability = SaaSAccountCapability.deserialize({
        'isPaying': false,
        'canUpgrade': true,
        'mailDnsConfigurationValidated': false,
      });

      expect(capability.mailDnsConfigurationValidated, isFalse);
      expect(capability.toJson()['mailDnsConfigurationValidated'], isFalse);
    });

    test('SHOULD tell capabilities apart by the field', () {
      expect(
        SaaSAccountCapability(mailDnsConfigurationValidated: false),
        isNot(SaaSAccountCapability()),
      );
    });
  });
}

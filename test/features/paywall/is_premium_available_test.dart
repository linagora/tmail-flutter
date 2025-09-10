import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/paywall/presentation/saas_premium_mixin.dart';

import '../../fixtures/account_fixtures.dart';

class TestClass with SaaSPremiumMixin {}

void main() {
  late TestClass testClass;

  setUp(() {
    testClass = TestClass();
  });

  group('SaaSPremiumMixin.isPremiumAvailable', () {
    test('should return false when accountId is null', () {
      final session = Session(
        {SessionExtensions.linagoraSaaSCapability: SaaSAccountCapability()},
        {},
        {},
        UserName('alice@domain.tld'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse(
            'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse(
            'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'),
      );
      final result = testClass.isPremiumAvailable(
        session: session,
        accountId: null,
      );
      expect(result, isFalse);
    });

    test('should return false when session is null', () {
      final accountId = AccountFixtures.aliceAccountId;
      final result = testClass.isPremiumAvailable(accountId: accountId);
      expect(result, isFalse);
    });

    test('should return false when session without SaaS capability', () {
      final accountId = AccountFixtures.aliceAccountId;
      final session = Session(
        {},
        {
          AccountFixtures.aliceAccountId:
              Account(AccountName('alice@domain.tld'), true, false, {})
        },
        {},
        UserName('alice@domain.tld'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse(
            'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse(
            'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'),
      );
      final result = testClass.isPremiumAvailable(
        session: session,
        accountId: accountId,
      );

      expect(result, isFalse);
    });

    test('should return false when SaaS capability has canUpgrade is false',
        () {
      final accountId = AccountFixtures.aliceAccountId;
      final session = Session(
        {
          SessionExtensions.linagoraSaaSCapability:
              SaaSAccountCapability(canUpgrade: false)
        },
        {
          AccountFixtures.aliceAccountId:
              Account(AccountName('alice@domain.tld'), true, false, {
            SessionExtensions.linagoraSaaSCapability:
                SaaSAccountCapability(canUpgrade: false),
          })
        },
        {
          SessionExtensions.linagoraSaaSCapability:
              AccountFixtures.aliceAccountId,
        },
        UserName('alice@domain.tld'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse(
            'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse(
            'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'),
      );

      final result = testClass.isPremiumAvailable(
        session: session,
        accountId: accountId,
      );

      expect(result, isFalse);
    });

    test('should return true when SaaS capability has canUpgrade is true', () {
      final accountId = AccountFixtures.aliceAccountId;
      final session = Session(
        {
          SessionExtensions.linagoraSaaSCapability:
              SaaSAccountCapability(canUpgrade: true)
        },
        {
          AccountFixtures.aliceAccountId:
              Account(AccountName('alice@domain.tld'), true, false, {
            SessionExtensions.linagoraSaaSCapability:
                SaaSAccountCapability(canUpgrade: true),
          })
        },
        {
          SessionExtensions.linagoraSaaSCapability:
              AccountFixtures.aliceAccountId,
        },
        UserName('alice@domain.tld'),
        Uri.parse('http://domain.com/jmap'),
        Uri.parse(
            'http://domain.com/download/{accountId}/{blobId}/?type={type}&name={name}'),
        Uri.parse('http://domain.com/upload/{accountId}'),
        Uri.parse(
            'http://domain.com/eventSource?types={types}&closeAfter={closeafter}&ping={ping}'),
        State('2c9f1b12-b35a-43e6-9af2-0106fb53a943'),
      );

      final result = testClass.isPremiumAvailable(
        session: session,
        accountId: accountId,
      );

      expect(result, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final session = DelegationFixtures.session();

  group('ActiveAccount.personal', () {
    final account = ActiveAccount.personal(session);

    test('shows my own account', () {
      expect(account.accountId, DelegationFixtures.aliceAccountId);
      expect(account.personalAccountId, DelegationFixtures.aliceAccountId);
      expect(account.isDelegated, isFalse);
    });

    test('has my address as the owner address', () {
      expect(account.ownerEmailAddress, DelegationFixtures.aliceAddress);
    });

    test('checks capabilities on my own account', () {
      expect(account.supportsCapability(DelegationFixtures.personalOnlyCapability), isTrue);
      expect(account.supportsCapability(DelegationFixtures.delegatedOnlyCapability), isFalse);
    });
  });

  group('ActiveAccount.delegated', () {
    final account = ActiveAccount.delegated(session, DelegationFixtures.bobAccountId);

    test('shows the delegated account and keeps my own account as personal', () {
      expect(account.accountId, DelegationFixtures.bobAccountId);
      expect(account.personalAccountId, DelegationFixtures.aliceAccountId);
      expect(account.isDelegated, isTrue);
    });

    test('has the owner address from the session account name', () {
      expect(account.ownerEmailAddress, DelegationFixtures.bobAddress);
    });

    test('checks capabilities on the delegated account, not on my own', () {
      expect(account.supportsCapability(DelegationFixtures.delegatedOnlyCapability), isTrue);
      expect(account.supportsCapability(DelegationFixtures.personalOnlyCapability), isFalse);
    });

    test('ignores a capability the session lists but the delegated account does not', () {
      expect(session.capabilities, contains(DelegationFixtures.personalOnlyCapability));
      expect(account.supportsCapability(DelegationFixtures.personalOnlyCapability), isFalse);
    });

    test('cannot be built for an account the session does not list as delegated', () {
      expect(
        () => ActiveAccount.delegated(session, DelegationFixtures.unknownAccountId),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ActiveAccount.delegated(session, DelegationFixtures.aliceAccountId),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('equality', () {
    test('is equal for the same session and account', () {
      expect(
        ActiveAccount.delegated(session, DelegationFixtures.bobAccountId),
        ActiveAccount.delegated(DelegationFixtures.session(), DelegationFixtures.bobAccountId),
      );
    });

    test('is not equal for another account of the same session', () {
      expect(
        ActiveAccount.delegated(session, DelegationFixtures.bobAccountId),
        isNot(ActiveAccount.delegated(session, DelegationFixtures.carolAccountId)),
      );
    });

    test('is not equal for the same account of another session', () {
      expect(
        ActiveAccount.personal(session),
        isNot(ActiveAccount.personal(DelegationFixtures.session(state: 'state-2'))),
      );
    });
  });
}

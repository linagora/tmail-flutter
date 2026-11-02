import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/owner_email_addresses.dart';

import '../../../../fixtures/delegation_fixtures.dart';

Identity _identity(String email) => Identity(email: email);

void main() {
  group('ownerEmailAddressesOf', () {
    final session = DelegationFixtures.session();
    final mine = ActiveAccount.personal(session);
    final bob = ActiveAccount.delegated(session, DelegationFixtures.bobAccountId);

    test('is the owner address before identities load', () {
      expect(ownerEmailAddressesOf(account: mine), {DelegationFixtures.aliceAddress});
      expect(ownerEmailAddressesOf(account: bob), {DelegationFixtures.bobAddress});
    });

    for (final caseData in [
      (
        name: 'adds the identities of the shown account',
        account: mine,
        identities: [
          _identity(DelegationFixtures.aliceAddress),
          _identity('alias@domain.tld'),
        ],
        teamMailboxEmails: const <String>[],
        expected: {DelegationFixtures.aliceAddress, 'alias@domain.tld'},
      ),
      (
        name: 'drops an identity that sends as another account of the session',
        account: mine,
        identities: [
          _identity('alias@domain.tld'),
          _identity(DelegationFixtures.bobAddress),
        ],
        teamMailboxEmails: const <String>[],
        expected: {DelegationFixtures.aliceAddress, 'alias@domain.tld'},
      ),
      (
        name: 'drops an identity that sends as a team mailbox of the shown account',
        account: bob,
        identities: [
          _identity('sales@domain.tld'),
          _identity('bob+team@domain.tld'),
        ],
        // Callers pass only team-root emails (isTeamMailboxRoot), not every folder name.
        teamMailboxEmails: const ['bob+team@domain.tld'],
        expected: {DelegationFixtures.bobAddress, 'sales@domain.tld'},
      ),
      (
        name: 'does not treat a personal folder name as a team mailbox to exclude',
        account: mine,
        identities: [_identity('alias@domain.tld')],
        teamMailboxEmails: const <String>[],
        expected: {DelegationFixtures.aliceAddress, 'alias@domain.tld'},
      ),
      (
        name: 'keeps the owner address even when it is also listed as a team mailbox',
        account: bob,
        identities: const <Identity>[],
        teamMailboxEmails: [DelegationFixtures.bobAddress],
        expected: {DelegationFixtures.bobAddress},
      ),
    ]) {
      test(caseData.name, () {
        expect(
          ownerEmailAddressesOf(
            account: caseData.account,
            identities: caseData.identities,
            teamMailboxEmails: caseData.teamMailboxEmails,
          ),
          caseData.expected,
        );
      });
    }
  });
}

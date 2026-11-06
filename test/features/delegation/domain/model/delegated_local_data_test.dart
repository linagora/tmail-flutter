import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/composer_snapshot_policy.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_cleanup.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_notification.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/offline_email_body_policy.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final mine = DelegationFixtures.aliceAccountId;
  final bob = DelegationFixtures.bobAccountId;
  final carol = DelegationFixtures.carolAccountId;
  final gone = DelegationFixtures.unknownAccountId;

  group('OfflineEmailBodyPolicy', () {
    test('stores a body of the personal account', () {
      expect(
        OfflineEmailBodyPolicy.mayStore(accountId: mine, personalAccountId: mine),
        isTrue,
      );
    });

    test('does not store a body of a delegated account', () {
      expect(
        OfflineEmailBodyPolicy.mayStore(accountId: bob, personalAccountId: mine),
        isFalse,
      );
    });
  });

  group('ComposerSnapshotPolicy', () {
    test('restores the snapshot of the account that is shown', () {
      expect(
        ComposerSnapshotPolicy.mayRestore(snapshotAccountId: mine, shownAccountId: mine),
        isTrue,
      );
      expect(
        ComposerSnapshotPolicy.mayRestore(snapshotAccountId: bob, shownAccountId: bob),
        isTrue,
      );
      expect(
        ComposerSnapshotPolicy.mayRestore(snapshotAccountId: bob, shownAccountId: mine),
        isFalse,
      );
    });

    test('logout removes a delegated snapshot of this user and keeps mine', () {
      expect(
        ComposerSnapshotPolicy.removeOnLogout(
          snapshotAccountId: bob,
          personalAccountId: mine,
          snapshotUserName: DelegationFixtures.aliceAddress,
          signedInUserName: DelegationFixtures.aliceAddress,
        ),
        isTrue,
      );
      expect(
        ComposerSnapshotPolicy.removeOnLogout(
          snapshotAccountId: mine,
          personalAccountId: mine,
          snapshotUserName: DelegationFixtures.aliceAddress,
          signedInUserName: DelegationFixtures.aliceAddress,
        ),
        isFalse,
      );
      expect(
        ComposerSnapshotPolicy.removeOnLogout(
          snapshotAccountId: bob,
          personalAccountId: mine,
          snapshotUserName: 'other@domain.tld',
          signedInUserName: DelegationFixtures.aliceAddress,
        ),
        isFalse,
      );
    });
  });

  group('EndedDelegationCleanup', () {
    test('deletes nothing for a cached session or when only mine is stored', () {
      expect(
        EndedDelegationCleanup.accountsToDelete(
          sessionFromCache: true,
          personalAccountId: mine,
          sessionAccountIds: {mine},
          storedAccountIds: {mine, gone},
        ),
        isEmpty,
      );
      expect(
        EndedDelegationCleanup.accountsToDelete(
          sessionFromCache: false,
          personalAccountId: mine,
          sessionAccountIds: {mine, bob},
          storedAccountIds: {mine},
        ),
        isEmpty,
      );
    });

    test('keeps the personal account and accounts the session still lists', () {
      final deleted = EndedDelegationCleanup.accountsToDelete(
        sessionFromCache: false,
        personalAccountId: mine,
        sessionAccountIds: {mine, bob},
        storedAccountIds: {mine, bob, carol, gone},
      );
      expect(deleted, containsAll([carol, gone]));
      expect(deleted, isNot(contains(mine)));
      expect(deleted, isNot(contains(bob)));
    });

    test('keychain removal drops only the ended account and keeps the entry', () {
      expect(
        EndedDelegationCleanup.keychainIdsAfterRemoval(
          [bob.id.value, carol.id.value],
          gone.id.value,
        ),
        [bob.id.value, carol.id.value],
      );
      final current = [bob.id.value, gone.id.value];
      expect(
        identical(
          EndedDelegationCleanup.keychainIdsAfterRemoval(current, 'missing'),
          current,
        ),
        isTrue,
      );
      expect(
        EndedDelegationCleanup.keychainIdsAfterRemoval(
          [bob.id.value, gone.id.value],
          gone.id.value,
        ),
        [bob.id.value],
      );
      expect(
        EndedDelegationCleanup.keychainIdsAfterRemoval([gone.id.value], gone.id.value),
        isNull,
      );
      expect(EndedDelegationCleanup.keychainIdsAfterRemoval(null, gone.id.value), isNull);
    });
  });

  group('ended delegation notifications', () {
    test('matches a payload of this user that names the account or one of its emails', () {
      expect(notificationGroupIsThisUser(DelegationFixtures.aliceAddress, DelegationFixtures.aliceAddress), isTrue);
      expect(notificationGroupIsThisUser(null, DelegationFixtures.aliceAddress), isTrue);
      expect(
        payloadNamesAccountOrEmail('{"accountId":"${gone.id.value}"}', gone.id.value, const {}),
        isTrue,
      );
      expect(
        payloadNamesAccountOrEmail('{"emailId":"email-1"}', gone.id.value, const {'email-1'}),
        isTrue,
      );
    });

    test('keeps a notification of another user, of mine, or one without a payload', () {
      expect(notificationGroupIsThisUser('other@domain.tld', DelegationFixtures.aliceAddress), isFalse);
      expect(notificationGroupIsThisUser(DelegationFixtures.aliceAddress, ''), isFalse);
      expect(
        payloadNamesAccountOrEmail('{"emailId":"mine-email"}', gone.id.value, const {'email-1'}),
        isFalse,
      );
      expect(payloadNamesAccountOrEmail(null, gone.id.value, const {'email-1'}), isFalse);
      expect(payloadNamesAccountOrEmail('{"emailId":"email-1"}', '', const {'email-1'}), isFalse);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_cleanup.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  final mine = DelegationFixtures.aliceAccountId;
  final bob = DelegationFixtures.bobAccountId;
  final gone = DelegationFixtures.unknownAccountId;

  group('CleanupEndedDelegationsInteractor', () {
    test('a cached session does not read or delete local data', () async {
      final store = _Store()..readsThrow = true;
      final result = await CleanupEndedDelegationsInteractor(store).execute(
        session: DelegationFixtures.session(),
        fromCache: true,
      );

      final success = result.getOrElse(() => throw StateError('failure'));
      expect(success, isA<CleanupEndedDelegationsSuccess>());
      final cleaned = success as CleanupEndedDelegationsSuccess;
      expect(cleaned.deletedAccountIds, isEmpty);
      expect(cleaned.lostCount, 0);
      expect(store.deleted, isEmpty);
    });

    test('deletes an account the session no longer lists and counts what is lost', () async {
      final store = _Store()
        ..stored.addAll({mine, bob, gone})
        ..rows[gone] = StoredDelegatedAccount(
          accountId: gone,
          unsentCount: 2,
          draftCount: 1,
        );
      final result = await CleanupEndedDelegationsInteractor(store).execute(
        session: DelegationFixtures.session(listsCarol: false),
        fromCache: false,
      );

      final cleaned = result.getOrElse(() => throw StateError('failure'))
          as CleanupEndedDelegationsSuccess;
      expect(cleaned.deletedAccountIds, [gone]);
      expect(cleaned.lostCount, 3);
      expect(store.deleted, [gone]);
      expect(store.personalAccountIds, [mine]);
    });

    test('does not delete an account whose lost-item count fails', () async {
      final store = _Store()
        ..stored.add(gone)
        ..failDescribe.add(gone);
      final result = await CleanupEndedDelegationsInteractor(store).execute(
        session: DelegationFixtures.session(listsCarol: false),
        fromCache: false,
      );

      final cleaned = result.getOrElse(() => throw StateError('failure'))
          as CleanupEndedDelegationsSuccess;
      expect(cleaned.deletedAccountIds, isEmpty);
      expect(cleaned.lostCount, 0);
      expect(store.deleted, isEmpty);
    });

    test('keeps going when one account fails and still reports the others', () async {
      final carol = DelegationFixtures.carolAccountId;
      final store = _Store()
        ..stored.addAll({gone, carol})
        ..failDelete.add(gone)
        ..rows[carol] = StoredDelegatedAccount(
          accountId: carol,
          unsentCount: 0,
          draftCount: 4,
        );
      final result = await CleanupEndedDelegationsInteractor(store).execute(
        session: DelegationFixtures.session(listsBob: false, listsCarol: false),
        fromCache: false,
      );

      final cleaned = result.getOrElse(() => throw StateError('failure'))
          as CleanupEndedDelegationsSuccess;
      expect(cleaned.deletedAccountIds, contains(carol));
      expect(cleaned.deletedAccountIds, isNot(contains(gone)));
      expect(cleaned.lostCount, 4);
    });
  });
}

class _Store implements EndedDelegationStore {
  final stored = <AccountId>{};
  final rows = <AccountId, StoredDelegatedAccount>{};
  final deleted = <AccountId>[];
  final personalAccountIds = <AccountId>[];
  final failDelete = <AccountId>{};
  final failDescribe = <AccountId>{};
  bool readsThrow = false;

  @override
  Future<Set<AccountId>> storedAccountIds({
    required UserName userName,
    required AccountId personalAccountId,
  }) async {
    if (readsThrow) throw StateError('read');
    return stored;
  }

  @override
  Future<StoredDelegatedAccount> describe(UserName userName, AccountId accountId) async {
    if (failDescribe.contains(accountId)) throw StateError('describe');
    return rows[accountId] ??
        StoredDelegatedAccount(accountId: accountId, unsentCount: 0, draftCount: 0);
  }

  @override
  Future<void> delete({
    required UserName userName,
    required AccountId personalAccountId,
    required AccountId accountId,
  }) async {
    personalAccountIds.add(personalAccountId);
    if (failDelete.contains(accountId)) throw StateError('delete');
    deleted.add(accountId);
  }

  @override
  Future<void> removeDelegatedComposerSnapshots({
    required UserName userName,
    required AccountId personalAccountId,
  }) async {}
}

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_cleanup.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';

class CleanupEndedDelegationsInteractor {
  final EndedDelegationStore _store;

  CleanupEndedDelegationsInteractor(this._store);

  Future<Either<Failure, Success>> execute({
    required Session session,
    required bool fromCache,
  }) async {
    try {
      if (fromCache) {
        return Right(CleanupEndedDelegationsSuccess(
          deletedAccountIds: const [],
          lostCount: 0,
        ));
      }
      final stored = await _store.storedAccountIds(
        userName: session.username,
        personalAccountId: session.accountId,
      );
      final toDelete = EndedDelegationCleanup.accountsToDelete(
        sessionFromCache: false,
        personalAccountId: session.accountId,
        sessionAccountIds: session.accounts.keys.toSet(),
        storedAccountIds: stored,
      );
      final deleted = <AccountId>[];
      var lost = 0;
      for (final accountId in toDelete) {
        try {
          final row = await _store.describe(session.username, accountId);
          await _store.delete(
            userName: session.username,
            personalAccountId: session.accountId,
            accountId: accountId,
          );
          deleted.add(accountId);
          lost += row.lostCount;
        } catch (error) {
          logWarning(
            'CleanupEndedDelegationsInteractor::execute: '
            'account=$accountId error=$error',
          );
        }
      }
      return Right(CleanupEndedDelegationsSuccess(
        deletedAccountIds: List.unmodifiable(deleted),
        lostCount: lost,
      ));
    } catch (error) {
      return Left(CleanupEndedDelegationsFailure(error));
    }
  }
}

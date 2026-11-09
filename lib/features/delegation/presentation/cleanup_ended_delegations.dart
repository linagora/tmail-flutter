import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// Deletes local data of accounts the session no longer lists.
///
/// A session read from cache returns 0 and deletes nothing. Returns how many
/// unsent messages and saved drafts were removed.
Future<int> cleanupEndedDelegations(
  Session session, {
  required bool fromCache,
}) async {
  final interactor = getBinding<CleanupEndedDelegationsInteractor>();
  if (interactor == null) return 0;
  final result = await interactor.execute(session: session, fromCache: fromCache);
  return result.fold(
    (_) => 0,
    (success) => success is CleanupEndedDelegationsSuccess ? success.lostCount : 0,
  );
}

/// Logout removes delegated composer snapshots of this user. Personal ones stay.
Future<void> removeDelegatedComposerSnapshotsOnLogout({
  required Session session,
  required AccountId personalAccountId,
}) async {
  final store = getBinding<EndedDelegationStore>();
  if (store == null) return;
  await store.removeDelegatedComposerSnapshots(
    userName: session.username,
    personalAccountId: personalAccountId,
  );
}

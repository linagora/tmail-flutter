import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
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

/// Warns when unsent messages or drafts were lost, [closedComposerCount] included.
/// With [revokedOwnerEmailAddress] and nothing lost, warns that the access ended.
Future<void> cleanupEndedDelegationsAndWarn(
  Session session, {
  required bool fromCache,
  int closedComposerCount = 0,
  String? revokedOwnerEmailAddress,
}) async {
  try {
    final lost = closedComposerCount + await cleanupEndedDelegations(session, fromCache: fromCache);
    if (lost <= 0 && revokedOwnerEmailAddress == null) return;
    showDelegationWarningToast(
      currentOverlayContext ?? currentContext,
      (l10n) => lost > 0
          ? l10n.endedDelegationLostItems(lost)
          : l10n.delegatedMailboxAccessEnded(revokedOwnerEmailAddress!),
    );
  } catch (error) {
    logWarning('cleanupEndedDelegationsAndWarn: $error');
  }
}

typedef LocalizedMessage = String Function(AppLocalizations l10n);

void showDelegationWarningToast(BuildContext? context, LocalizedMessage messageOf) {
  final appToast = getBinding<AppToast>();
  if (appToast == null) return;
  if (context == null || !context.mounted) return;
  appToast.showToastWarningMessage(context, messageOf(AppLocalizations.of(context)));
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

import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/session_reload.dart';
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

/// One toast for an ended delegation: what was lost, else that the access ended, then what was kept.
///
/// [reload] carries what the session re-read did to the shown mailbox, if it ended.
Future<void> cleanupEndedDelegationsAndWarn(
  Session session, {
  required bool fromCache,
  SessionReload? reload,
}) async {
  try {
    final lost = (reload?.lostComposerCount ?? 0) + await cleanupEndedDelegations(session, fromCache: fromCache);
    final revokedOwner = reload?.revokedOwnerEmailAddress;
    if (lost <= 0 && revokedOwner == null) return;
    showDelegationWarningToast(
      currentOverlayContext ?? currentContext,
      (l10n) => [
        lost > 0 ? l10n.endedDelegationLostItems(lost) : l10n.delegatedMailboxAccessEnded(revokedOwner!),
        ...keptWorkMessages(l10n, reload),
      ].join(' '),
    );
  } catch (error) {
    logWarning('cleanupEndedDelegationsAndWarn: $error');
  }
}

typedef LocalizedMessage = String Function(AppLocalizations l10n);

/// What reopened in the user's own mailbox, and the attachments that could not follow.
List<String> keptWorkMessages(AppLocalizations l10n, SessionReload? reload) {
  final keptComposerCount = reload?.keptComposerCount ?? 0;
  final droppedAttachmentNames = reload?.droppedAttachmentNames ?? const <String>[];
  return [
    if (keptComposerCount > 0) l10n.endedDelegationComposersKept(keptComposerCount),
    if (droppedAttachmentNames.isNotEmpty) l10n.endedDelegationAttachmentsNotKept(droppedAttachmentNames.join(', ')),
  ];
}

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

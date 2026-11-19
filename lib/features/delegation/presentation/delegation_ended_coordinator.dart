import 'package:core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/base/interactor_consumer.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/delegation_ended_handler.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_ended_handlers_provider.dart';

typedef DelegationLeave = ({
  int lostComposerCount,
  int keptComposerCount,
  List<String> droppedAttachmentNames,
  bool couldNotReturnToMine,
});

final delegationEndedCoordinatorProvider = Provider<DelegationEndedCoordinator>(DelegationEndedCoordinator.new);

/// Leaves a shown delegated mailbox that the session no longer lists. See ADR-0114 §Revocation.
class DelegationEndedCoordinator {
  final Ref _ref;

  const DelegationEndedCoordinator(this._ref);

  /// A cancelled switch is not a failure: a newer switch replaced it.
  Future<DelegationLeave?> leave(ActiveAccount endedAccount, StaleGuard isStale) async {
    final view = _ref.read(dashboardAccountSwitchViewProvider)();
    if (view == null) return null;
    final afterLeaves = await _runHandlers();
    // A sign-out during a handler must not close the composers of the next login.
    if (isStale()) return null;
    try {
      // The composers kept by a handler close here too, and count as lost unless they reopen.
      final closedComposerCount = await view.closeComposers();
      // A sign-out during the close must not switch the account of the next login.
      if (isStale()) return null;

      // A mailbox picked by the user during the close wins over the return to their own one.
      final pickedByUser = _shownAccountId != endedAccount.accountId;
      final result = pickedByUser
          ? null
          : await _ref
                .read(accountSwitchProvider.notifier)
                .switchTo(endedAccount.personalAccountId, view, closesOpenComposer: true);
      // A failed or timed out switch still falls back to mine, so the kept work reopens there too.
      final kept = await _runAfterLeave(
        afterLeaves,
        () => !isStale() && _shownAccountId == endedAccount.personalAccountId,
      );
      final keptComposerCount = kept.fold(0, (count, handling) => count + handling.keptComposerCount);
      return (
        lostComposerCount: (closedComposerCount - keptComposerCount).clamp(0, closedComposerCount),
        keptComposerCount: keptComposerCount,
        droppedAttachmentNames: [for (final handling in kept) ...handling.droppedAttachmentNames],
        couldNotReturnToMine: result is AccountSwitchFailed || result is AccountSwitchTimedOut,
      );
    } catch (error, stackTrace) {
      // The session is still applied, so the ended account is dropped and only the error toast shows.
      logError('DelegationEndedCoordinator::leave: ${error.runtimeType}', exception: error, stackTrace: stackTrace);
      return (
        lostComposerCount: 0,
        keptComposerCount: 0,
        droppedAttachmentNames: const <String>[],
        couldNotReturnToMine: true,
      );
    }
  }

  AccountId? get _shownAccountId => _ref.read(activeAccountProvider)?.accountId;

  /// One failing handler must not stop the others or the switch.
  Future<List<AfterDelegationLeft>> _runHandlers() async {
    final afterLeaves = <AfterDelegationLeft>[];
    for (final handler in _ref.read(delegationEndedHandlersProvider)) {
      try {
        final afterLeave = await handler.beforeLeave();
        if (afterLeave != null) afterLeaves.add(afterLeave);
      } catch (error, stackTrace) {
        logError(
          'DelegationEndedCoordinator::_runHandlers: ${error.runtimeType}',
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
    return afterLeaves;
  }

  /// Returns the work now reopened in the user's own mailbox.
  Future<List<DelegationEndedHandling>> _runAfterLeave(
    List<AfterDelegationLeft> afterLeaves,
    ShowsMine showsMine,
  ) async {
    final kept = <DelegationEndedHandling>[];
    for (final afterLeave in afterLeaves) {
      if (!showsMine()) break;
      try {
        kept.add(await afterLeave(showsMine));
      } catch (error, stackTrace) {
        logError(
          'DelegationEndedCoordinator::_runAfterLeave: ${error.runtimeType}',
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
    return kept;
  }
}

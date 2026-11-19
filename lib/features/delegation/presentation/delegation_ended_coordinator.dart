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
    final handlings = await _runHandlers();
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
      final showsMine = !isStale() && _shownAccountId == endedAccount.personalAccountId;
      final kept = showsMine
          ? await _runAfterLeave(handlings)
          : const <DelegationEndedHandling>[];
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
  Future<List<DelegationEndedHandling>> _runHandlers() async {
    final handlings = <DelegationEndedHandling>[];
    for (final handler in _ref.read(delegationEndedHandlersProvider)) {
      try {
        handlings.add(await handler.beforeLeave());
      } catch (error, stackTrace) {
        logError(
          'DelegationEndedCoordinator::_runHandlers: ${error.runtimeType}',
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
    return handlings;
  }

  /// Returns the handlings whose work is now in the user's own mailbox.
  Future<List<DelegationEndedHandling>> _runAfterLeave(List<DelegationEndedHandling> handlings) async {
    final kept = <DelegationEndedHandling>[];
    for (final handling in handlings) {
      try {
        await handling.afterLeave?.call();
        kept.add(handling);
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

import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/switch_attempt.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

part 'account_switch_notifier.g.dart';

typedef ViewStep = void Function();

/// Switches the shown mailbox between my account and a delegated one. See ADR-0114.
@Riverpod(keepAlive: true)
class AccountSwitchNotifier extends _$AccountSwitchNotifier {
  static const switchTimeout = Duration(seconds: 30);

  Completer<void>? _cancellation;

  @override
  AccountSwitchState build() {
    ref.listen<ActiveAccount?>(activeAccountProvider, (previous, next) {
      if (state.isSwitching) return;
      if (previous == null || next == null) return;
      if (_sameShownAccount(previous, next)) return;

      state = AccountSwitchIdle(lastAttemptId: state.currentAttemptId + 1);
    });
    return const AccountSwitchIdle();
  }

  ActiveAccountNotifier get _activeAccountNotifier =>
      ref.read(activeAccountProvider.notifier);

  ActiveAccount? get _shownAccount => ref.read(activeAccountProvider);

  Future<AccountSwitchResult> switchTo(
    AccountId targetAccountId,
    AccountSwitchView view,
  ) async {
    final previousAccount = _shownAccount;
    final refusal = _findRefusal(previousAccount, targetAccountId, view);
    if (refusal != null) return AccountSwitchRefused(refusal);

    _startAttempt(from: previousAccount!.accountId, to: targetAccountId);
    final cancellation = _cancellation = Completer<void>();
    try {
      final preparationFailure = _prepareView(view);
      final result = preparationFailure ??
          await _showTarget(view, targetAccountId, cancellation);
      if (state is AccountSwitchEndingSession) {
        return const AccountSwitchCancelled();
      }
      if (result is! AccountSwitched && _shownAccount != null) {
        _fallBackTo(
          previousAccount,
          targetAccountId,
          view,
          restoresSelection: preparationFailure == null,
        );
      }
      return result;
    } finally {
      final endingSession = state is AccountSwitchEndingSession;
      _cancellation = null;
      if (!endingSession) _runViewStep('unblockInput', view.unblockInput);
      state = AccountSwitchIdle(lastAttemptId: state.currentAttemptId);
    }
  }

  void cancel() {
    final cancellation = _cancellation;
    if (cancellation != null && !cancellation.isCompleted) {
      cancellation.complete();
    }
  }

  /// Drops in-flight view results of the current attempt. The id only increases,
  /// so a late result of a previous session cannot match a later attempt.
  void endSession() {
    if (state is AccountSwitchEndingSession) return;

    final nextAttemptId = state.currentAttemptId + 1;
    if (state.isSwitching) {
      state = AccountSwitchEndingSession(nextAttemptId);
      cancel();
    } else {
      state = AccountSwitchIdle(lastAttemptId: nextAttemptId);
    }

    _activeAccountNotifier.clear();
  }

  bool _sameShownAccount(ActiveAccount previous, ActiveAccount next) {
    return previous.accountId == next.accountId &&
        previous.session.username == next.session.username;
  }

  AccountSwitchRefusal? _findRefusal(
    ActiveAccount? shownAccount,
    AccountId targetAccountId,
    AccountSwitchView view,
  ) {
    if (state.isSwitching) return AccountSwitchRefusal.switchInProgress;
    if (view.hasOpenComposer) return AccountSwitchRefusal.composerOpen;
    if (shownAccount == null) return AccountSwitchRefusal.accountNotListed;
    if (shownAccount.accountId == targetAccountId) {
      return AccountSwitchRefusal.accountAlreadyShown;
    }
    return _activeAccountNotifier.canSelect(targetAccountId)
        ? null
        : AccountSwitchRefusal.accountNotListed;
  }

  void _startAttempt({required AccountId from, required AccountId to}) {
    state = AccountSwitching(
      SwitchAttempt(id: state.currentAttemptId + 1, from: from, to: to),
    );
  }

  /// A failing view step fails the switch, so the caller still gets a result to show.
  AccountSwitchFailed? _prepareView(AccountSwitchView view) {
    try {
      view.blockInput();
      view.keepSelectionAndSearch();
      return null;
    } catch (error, stackTrace) {
      return AccountSwitchFailed(error, stackTrace);
    }
  }

  /// A switch cancelled, or whose target left the session, during the view steps is not loaded.
  Future<AccountSwitchResult> _showTarget(
    AccountSwitchView view,
    AccountId targetAccountId,
    Completer<void> cancellation,
  ) async {
    if (cancellation.isCompleted || !_activeAccountNotifier.select(targetAccountId)) {
      return const AccountSwitchCancelled();
    }
    return _cancelIfTargetLeft(
      await _waitForShownAccount(view, targetAccountId, cancellation.future),
      targetAccountId,
    );
  }

  Future<AccountSwitchResult> _waitForShownAccount(
    AccountSwitchView view,
    AccountId targetAccountId,
    Future<void> cancelled,
  ) async {
    final targetLeaving = _cancelWhenTargetLeaves(targetAccountId);
    final loaded = Future.sync(
      () => view.loadAccount(_shownAccount!, state.currentAttemptId),
    ).then<AccountSwitchResult>(
      (_) => const AccountSwitched(),
      onError: (Object error, StackTrace stackTrace) =>
          AccountSwitchFailed(error, stackTrace),
    );
    final cancelledResult = cancelled.then<AccountSwitchResult>(
      (_) => const AccountSwitchCancelled(),
    );

    try {
      return await Future.any([loaded, cancelledResult]).timeout(
        switchTimeout,
        onTimeout: () => const AccountSwitchTimedOut(),
      );
    } finally {
      targetLeaving.close();
    }
  }

  ProviderSubscription<ActiveAccount?> _cancelWhenTargetLeaves(
    AccountId targetAccountId,
  ) {
    return ref.listen<ActiveAccount?>(activeAccountProvider, (_, shownAccount) {
      if (shownAccount?.accountId != targetAccountId) cancel();
    });
  }

  AccountSwitchResult _cancelIfTargetLeft(
    AccountSwitchResult result,
    AccountId targetAccountId,
  ) {
    final isTargetStillShown = _shownAccount?.accountId == targetAccountId;
    return result is AccountSwitched && !isTargetStillShown
        ? const AccountSwitchCancelled()
        : result;
  }

  /// A selection that was never kept is not restored.
  void _fallBackTo(
    ActiveAccount previousAccount,
    AccountId targetAccountId,
    AccountSwitchView view, {
    required bool restoresSelection,
  }) {
    final isSwitchToPersonal = targetAccountId == previousAccount.personalAccountId;
    final restoresPreviousAccount = !isSwitchToPersonal &&
        _activeAccountNotifier.canSelect(previousAccount.accountId);
    final shownAccount = _shownAccount;
    if (shownAccount == null) return;

    _startAttempt(
      from: shownAccount.accountId,
      to: restoresPreviousAccount
          ? previousAccount.accountId
          : shownAccount.personalAccountId,
    );
    if (restoresPreviousAccount) {
      _activeAccountNotifier.select(previousAccount.accountId);
      if (restoresSelection) {
        _runViewStep('restoreSelectionAndSearch', view.restoreSelectionAndSearch);
      }
    } else {
      _activeAccountNotifier.selectPersonal();
    }
    _runViewStep(
      'catchUpAccount',
      () => view.catchUpAccount(_shownAccount!, state.currentAttemptId),
    );
  }

  /// A failing step must not hide the switch result the caller shows in its toast.
  void _runViewStep(String stepName, ViewStep step) {
    try {
      step();
    } catch (error, stackTrace) {
      logError(
        'AccountSwitchNotifier::_runViewStep: $stepName failed',
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}

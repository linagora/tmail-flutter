import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/switch_attempt.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../../../fixtures/delegation_fixtures.dart';

typedef ViewStepCallback = void Function();

class FakeAccountSwitchView implements AccountSwitchView {
  @override
  bool hasOpenComposer = false;

  final List<String> calls = [];
  final List<Completer<void>> loadings = [];
  Object? errorThrownByLoadAccount;
  Object? errorThrownByRestoreSelectionAndSearch;
  Object? errorThrownByCatchUpAccount;
  Object? errorThrownByUnblockInput;
  ViewStepCallback? onBlockInput;
  ViewStepCallback? onKeepSelectionAndSearch;

  @override
  void blockInput() {
    calls.add('blockInput');
    onBlockInput?.call();
  }

  @override
  void unblockInput() {
    calls.add('unblockInput');
    final error = errorThrownByUnblockInput;
    if (error != null) throw error;
  }

  @override
  void keepSelectionAndSearch() {
    calls.add('keepSelectionAndSearch');
    onKeepSelectionAndSearch?.call();
  }

  @override
  void restoreSelectionAndSearch() {
    calls.add('restoreSelectionAndSearch');
    final error = errorThrownByRestoreSelectionAndSearch;
    if (error != null) throw error;
  }

  @override
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId) {
    calls.add('loadAccount(${account.accountId.id.value}, $switchAttemptId)');
    final error = errorThrownByLoadAccount;
    if (error != null) throw error;
    final loading = Completer<void>();
    loadings.add(loading);
    return loading.future;
  }

  @override
  void catchUpAccount(ActiveAccount account, int switchAttemptId) {
    calls.add('catchUpAccount(${account.accountId.id.value}, $switchAttemptId)');
    final error = errorThrownByCatchUpAccount;
    if (error != null) throw error;
  }
}

void main() {
  final alice = DelegationFixtures.aliceAccountId;
  final bob = DelegationFixtures.bobAccountId;
  final carol = DelegationFixtures.carolAccountId;

  late ProviderContainer container;
  late FakeAccountSwitchView view;
  late Session session;

  AccountSwitchNotifier switchNotifierOf() => container.read(accountSwitchProvider.notifier);
  AccountSwitchState switchStateOf() => container.read(accountSwitchProvider);
  ActiveAccountNotifier activeAccountNotifierOf() => container.read(activeAccountProvider.notifier);
  ActiveAccount? shownAccountOf() => container.read(activeAccountProvider);

  setUp(() {
    container = ProviderContainer();
    view = FakeAccountSwitchView();
    session = DelegationFixtures.session();
    activeAccountNotifierOf().applySession(session);
  });

  tearDown(() => container.dispose());

  Future<void> showBobMailbox() async {
    final toBob = switchNotifierOf().switchTo(bob, view);
    view.loadings.last.complete();
    await toBob;
    view.calls.clear();
    view.loadings.clear();
  }

  /// Checks a switch that a view step ends before the target is shown: only the way back to my
  /// account runs, with a new attempt, and no other account is ever shown.
  Future<void> expectSwitchEndsOnMyAccountInViewSteps(
    AccountId target, {
    required Matcher result,
    required List<String> viewStepCalls,
  }) async {
    final wayBackAttemptId = switchStateOf().currentAttemptId + 2;
    final seen = <ActiveAccount?>[];
    container.listen<ActiveAccount?>(activeAccountProvider, (_, account) => seen.add(account));

    expect(await switchNotifierOf().switchTo(target, view), result);
    expect(seen, everyElement(ActiveAccount.personal(session)));
    expect(shownAccountOf(), ActiveAccount.personal(session));
    expect(switchStateOf(), AccountSwitchIdle(lastAttemptId: wayBackAttemptId));
    expect(view.calls, [
      ...viewStepCalls,
      'catchUpAccount(${alice.id.value}, $wayBackAttemptId)',
      'unblockInput',
    ]);
  }

  group('switchTo: success', () {
    test('shows the target account and runs the steps in order', () async {
      final switching = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.complete();

      expect(await switching, const AccountSwitched());
      expect(shownAccountOf(), ActiveAccount.delegated(session, bob));
      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'loadAccount(bob-account-id, 1)',
        'unblockInput',
      ]);
    });

    test('marks the switch as running until the target account is loaded', () async {
      final switching = switchNotifierOf().switchTo(bob, view);

      expect(switchStateOf(), AccountSwitching(SwitchAttempt(id: 1, from: alice, to: bob)));

      view.loadings.single.complete();
      await switching;

      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 1));
      expect(switchStateOf().isSwitching, isFalse);
    });

    test('shows my own account again from a delegated one', () async {
      await showBobMailbox();

      final switching = switchNotifierOf().switchTo(alice, view);
      view.loadings.single.complete();

      expect(await switching, const AccountSwitched());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
    });

    test('loads the target with a new attempt id, so results of the previous attempt can be dropped', () async {
      await showBobMailbox();

      final switching = switchNotifierOf().switchTo(carol, view);
      view.loadings.single.complete();
      await switching;

      expect(view.calls, contains('loadAccount(carol-account-id, 2)'));
      expect(switchStateOf().currentAttemptId, 2);
    });
  });

  group('switchTo: refused', () {
    test('while another switch runs, without touching the view', () async {
      final running = switchNotifierOf().switchTo(bob, view);
      final secondView = FakeAccountSwitchView();

      final result = await switchNotifierOf().switchTo(carol, secondView);

      expect(result, const AccountSwitchRefused(AccountSwitchRefusal.switchInProgress));
      expect(secondView.calls, isEmpty);
      view.loadings.single.complete();
      await running;
      expect(shownAccountOf()!.accountId, bob);
    });

    test('while a composer is open, without starting an attempt', () async {
      view.hasOpenComposer = true;

      final result = await switchNotifierOf().switchTo(bob, view);

      expect(result, const AccountSwitchRefused(AccountSwitchRefusal.composerOpen));
      expect(view.calls, isEmpty);
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle());
    });

    test('when the target account is already shown', () async {
      final result = await switchNotifierOf().switchTo(alice, view);

      expect(result, const AccountSwitchRefused(AccountSwitchRefusal.accountAlreadyShown));
      expect(view.calls, isEmpty);
    });

    test('when the session does not list the target account', () async {
      final result = await switchNotifierOf().switchTo(DelegationFixtures.unknownAccountId, view);

      expect(result, const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed));
      expect(view.calls, isEmpty);
      expect(shownAccountOf(), ActiveAccount.personal(session));
    });

    test('before a session is applied', () async {
      final emptyContainer = ProviderContainer();
      addTearDown(emptyContainer.dispose);

      final result = await emptyContainer.read(accountSwitchProvider.notifier).switchTo(bob, view);

      expect(result, const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed));
      expect(view.calls, isEmpty);
    });
  });

  group('switchTo: rollback to the previous account', () {
    test('on failure: restores my account, its selection and search, then catches up with a new attempt', () async {
      final error = Exception('load failed');
      final switching = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.completeError(error);

      final result = await switching;

      expect(result, isA<AccountSwitchFailed>().having((failed) => failed.error, 'error', error));
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'loadAccount(bob-account-id, 1)',
        'restoreSelectionAndSearch',
        'catchUpAccount(${alice.id.value}, 2)',
        'unblockInput',
      ]);
    });

    test('when loadAccount throws before returning a future', () async {
      view.errorThrownByLoadAccount = StateError('cannot load');

      final result = await switchNotifierOf().switchTo(bob, view);

      expect(result, isA<AccountSwitchFailed>());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(view.calls.last, 'unblockInput');
    });

    test('when blocking input throws: fails without selecting the target or restoring a selection never kept', () async {
      final error = StateError('cannot block input');
      view.onBlockInput = () => throw error;

      await expectSwitchEndsOnMyAccountInViewSteps(
        bob,
        result: isA<AccountSwitchFailed>().having((failed) => failed.error, 'error', error),
        viewStepCalls: ['blockInput'],
      );
    });

    test('when keeping the selection throws: fails without selecting the target or restoring a selection never kept', () async {
      final error = StateError('cannot keep the selection');
      view.onKeepSelectionAndSearch = () => throw error;

      await expectSwitchEndsOnMyAccountInViewSteps(
        bob,
        result: isA<AccountSwitchFailed>().having((failed) => failed.error, 'error', error),
        viewStepCalls: ['blockInput', 'keepSelectionAndSearch'],
      );
    });

    test('on cancel: rolls back and ignores the late load of the cancelled switch', () async {
      final switching = switchNotifierOf().switchTo(bob, view);

      switchNotifierOf().cancel();
      final result = await switching;
      view.loadings.single.complete();
      await Future<void>.delayed(Duration.zero);

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
      expect(view.calls, contains('restoreSelectionAndSearch'));
      expect(view.calls.last, 'unblockInput');
    });

    test('on timeout after 30 s, and not before', () {
      fakeAsync((async) {
        AccountSwitchResult? result;
        switchNotifierOf().switchTo(bob, view).then((value) => result = value);

        async.elapse(const Duration(seconds: 29));
        expect(result, isNull);
        expect(switchStateOf().isSwitching, isTrue);

        async.elapse(const Duration(seconds: 1));
        expect(result, const AccountSwitchTimedOut());
        expect(shownAccountOf(), ActiveAccount.personal(session));
        expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));

        view.loadings.single.completeError(Exception('late failure'));
        async.flushMicrotasks();
        expect(shownAccountOf(), ActiveAccount.personal(session));
      });
    });

    test('when restoring the selection throws: still catches up and returns the failure', () async {
      final error = Exception('load failed');
      view.errorThrownByRestoreSelectionAndSearch = StateError('cannot restore');
      final switching = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.completeError(error);

      final result = await switching;

      expect(result, isA<AccountSwitchFailed>().having((failed) => failed.error, 'error', error));
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
      expect(view.calls, containsAllInOrder([
        'restoreSelectionAndSearch',
        'catchUpAccount(${alice.id.value}, 2)',
        'unblockInput',
      ]));
    });

    test('when catching up throws: still returns the cancel and unblocks input', () async {
      view.errorThrownByCatchUpAccount = StateError('cannot catch up');
      final switching = switchNotifierOf().switchTo(bob, view);
      switchNotifierOf().cancel();

      expect(await switching, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
      expect(view.calls.last, 'unblockInput');
    });

    test('from one delegated account to another: goes back to the first one', () async {
      await showBobMailbox();

      final switching = switchNotifierOf().switchTo(carol, view);
      view.loadings.single.completeError(Exception('load failed'));

      expect(await switching, isA<AccountSwitchFailed>());
      expect(shownAccountOf(), ActiveAccount.delegated(session, bob));
      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'loadAccount(carol-account-id, 2)',
        'restoreSelectionAndSearch',
        'catchUpAccount(bob-account-id, 3)',
        'unblockInput',
      ]);
    });

    test('to my own account when the previous delegated account left the session meanwhile', () async {
      await showBobMailbox();

      final toCarol = switchNotifierOf().switchTo(carol, view);
      final sessionWithoutBob = DelegationFixtures.session(listsBob: false, state: 'state-2');
      activeAccountNotifierOf().applySession(sessionWithoutBob);
      view.loadings.last.completeError(Exception('load failed'));
      await toCarol;

      expect(shownAccountOf(), ActiveAccount.personal(sessionWithoutBob));
      expect(view.calls, isNot(contains('restoreSelectionAndSearch')));
      expect(
        view.calls,
        contains('catchUpAccount(${alice.id.value}, 3)'),
      );
    });
  });

  group('switchTo: to my own account never rolls back to a delegated one', () {
    test('on failure: stays on my account and catches it up with a new attempt, without restoring the selection', () async {
      await showBobMailbox();

      final toAlice = switchNotifierOf().switchTo(alice, view);
      view.loadings.last.completeError(Exception('load failed'));
      final result = await toAlice;

      expect(result, isA<AccountSwitchFailed>());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 3));
      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'loadAccount(${alice.id.value}, 2)',
        'catchUpAccount(${alice.id.value}, 3)',
        'unblockInput',
      ]);
    });

    test('on cancel: stays on my account, so the late load of the cancelled switch is dropped', () async {
      await showBobMailbox();

      final toAlice = switchNotifierOf().switchTo(alice, view);
      switchNotifierOf().cancel();
      final result = await toAlice;
      view.loadings.single.complete();

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(switchStateOf().currentAttemptId, 3);
      expect(view.calls, isNot(contains('restoreSelectionAndSearch')));
    });

    test('when a view step throws: shows my account and catches it up, without restoring the selection', () async {
      await showBobMailbox();
      view.onBlockInput = () => throw StateError('cannot block input');

      await expectSwitchEndsOnMyAccountInViewSteps(
        alice,
        result: isA<AccountSwitchFailed>(),
        viewStepCalls: ['blockInput'],
      );
    });

    test('on cancel during the view steps: shows my account and catches it up, without loading it first', () async {
      await showBobMailbox();
      view.onBlockInput = () => switchNotifierOf().cancel();

      await expectSwitchEndsOnMyAccountInViewSteps(
        alice,
        result: equals(const AccountSwitchCancelled()),
        viewStepCalls: ['blockInput', 'keepSelectionAndSearch'],
      );
    });

    test('on timeout: stays on my account with a new attempt', () {
      fakeAsync((async) {
        AccountSwitchResult? result;
        final toBob = switchNotifierOf().switchTo(bob, view);
        view.loadings.single.complete();
        async.flushMicrotasks();
        view.calls.clear();
        toBob.then((_) => switchNotifierOf().switchTo(alice, view).then((value) => result = value));
        async.flushMicrotasks();

        async.elapse(AccountSwitchNotifier.switchTimeout);

        expect(result, const AccountSwitchTimedOut());
        expect(shownAccountOf(), ActiveAccount.personal(session));
        expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 3));
        expect(view.calls, contains('catchUpAccount(${alice.id.value}, 3)'));
      });
    });
  });

  group('switchTo: target account leaves the session during the switch', () {
    test('a successful load is reported as cancelled and the previous account comes back', () async {
      await showBobMailbox();

      final toCarol = switchNotifierOf().switchTo(carol, view);
      final sessionWithoutCarol = DelegationFixtures.session(listsCarol: false, state: 'state-2');
      activeAccountNotifierOf().applySession(sessionWithoutCarol);
      view.loadings.single.complete();
      final result = await toCarol;

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.delegated(sessionWithoutCarol, bob));
      expect(switchStateOf().currentAttemptId, 3);
      expect(view.calls, containsAllInOrder(['restoreSelectionAndSearch', 'catchUpAccount(bob-account-id, 3)']));
    });

    test('a target that leaves during the view steps is not loaded and the switch is cancelled at once', () async {
      final sessionWithoutBob = DelegationFixtures.session(listsBob: false, state: 'state-2');
      view.onKeepSelectionAndSearch = () => activeAccountNotifierOf().applySession(sessionWithoutBob);

      final result = await switchNotifierOf().switchTo(bob, view);

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.personal(sessionWithoutBob));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'restoreSelectionAndSearch',
        'catchUpAccount(${alice.id.value}, 2)',
        'unblockInput',
      ]);
    });

    test('a load that ends just before the target leaves is still reported as cancelled', () async {
      await showBobMailbox();

      final toCarol = switchNotifierOf().switchTo(carol, view);
      view.loadings.single.complete();
      final sessionWithoutCarol = DelegationFixtures.session(listsCarol: false, state: 'state-2');
      activeAccountNotifierOf().applySession(sessionWithoutCarol);

      expect(await toCarol, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.delegated(sessionWithoutCarol, bob));
    });

    test('the switch is cancelled at once, without waiting for the load', () async {
      await showBobMailbox();

      AccountSwitchResult? result;
      switchNotifierOf().switchTo(carol, view).then((value) => result = value);
      final sessionWithoutCarol = DelegationFixtures.session(listsCarol: false, state: 'state-2');
      activeAccountNotifierOf().applySession(sessionWithoutCarol);
      await pumpEventQueue();

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.delegated(sessionWithoutCarol, bob));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 3));
      expect(view.calls.last, 'unblockInput');

      view.loadings.single.complete();
      await Future<void>.delayed(Duration.zero);
      expect(shownAccountOf(), ActiveAccount.delegated(sessionWithoutCarol, bob));
    });

    test('a new session that still lists the target does not cancel the switch', () async {
      final toBob = switchNotifierOf().switchTo(bob, view);
      final refreshedSession = DelegationFixtures.session(state: 'state-2');
      activeAccountNotifierOf().applySession(refreshedSession);
      view.loadings.single.complete();

      expect(await toBob, const AccountSwitched());
      expect(shownAccountOf(), ActiveAccount.delegated(refreshedSession, bob));
    });

    test(
      'a target leaving after the switch ended starts a new attempt, so in-flight results of it fail the stale check',
      () async {
        await showBobMailbox();

        final sessionWithoutBob =
            DelegationFixtures.session(listsBob: false, state: 'state-2');
        activeAccountNotifierOf().applySession(sessionWithoutBob);

        expect(shownAccountOf(), ActiveAccount.personal(sessionWithoutBob));
        expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
        expect(view.calls, isEmpty);
      },
    );

    test(
      'another user signing in starts a new attempt even when the personal account id is reused',
      () async {
        final otherUserSession = DelegationFixtures.session(
          username: DelegationFixtures.carolAddress,
          state: 'state-2',
        );

        switchNotifierOf();
        activeAccountNotifierOf().applySession(otherUserSession);

        expect(shownAccountOf(), ActiveAccount.personal(otherUserSession));
        expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 1));
      },
    );

    test('a cancelled switch also comes back to the previous account with a new attempt', () async {
      await showBobMailbox();

      final toCarol = switchNotifierOf().switchTo(carol, view);
      final sessionWithoutCarol = DelegationFixtures.session(listsCarol: false, state: 'state-2');
      activeAccountNotifierOf().applySession(sessionWithoutCarol);
      switchNotifierOf().cancel();
      final result = await toCarol;

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.delegated(sessionWithoutCarol, bob));
      expect(view.calls, contains('catchUpAccount(bob-account-id, 3)'));
    });
  });

  group('switchTo: order of state changes', () {
    test('a listener of the shown account already sees the running attempt, the way back included', () async {
      final seen = <AccountSwitchState>[];
      container.listen<ActiveAccount?>(activeAccountProvider, (_, __) => seen.add(switchStateOf()));

      final switching = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.completeError(Exception('load failed'));
      await switching;

      expect(seen, [
        AccountSwitching(SwitchAttempt(id: 1, from: alice, to: bob)),
        AccountSwitching(SwitchAttempt(id: 2, from: bob, to: alice)),
      ]);
    });

    test('the way back goes to my own account when the previous delegated account left the session', () async {
      await showBobMailbox();
      final seen = <AccountSwitchState>[];
      container.listen<ActiveAccount?>(activeAccountProvider, (_, __) => seen.add(switchStateOf()));

      final toCarol = switchNotifierOf().switchTo(carol, view);
      activeAccountNotifierOf().applySession(DelegationFixtures.session(listsBob: false, state: 'state-2'));
      view.loadings.single.completeError(Exception('load failed'));
      await toCarol;

      expect(seen.last, AccountSwitching(SwitchAttempt(id: 3, from: carol, to: alice)));
    });

    test('a switch asked from inside a view step is refused as already running', () async {
      AccountSwitchResult? innerResult;
      view.onKeepSelectionAndSearch = () {
        view.onKeepSelectionAndSearch = null;
        switchNotifierOf().switchTo(carol, view).then((value) => innerResult = value);
      };

      final switching = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.complete();
      await switching;

      expect(innerResult, const AccountSwitchRefused(AccountSwitchRefusal.switchInProgress));
      expect(shownAccountOf(), ActiveAccount.delegated(session, bob));
    });

    test('input is unblocked before the switch ends, so a switch started once it ends keeps input blocked', () async {
      Future<AccountSwitchResult>? toCarol;
      container.listen<AccountSwitchState>(accountSwitchProvider, (_, state) {
        if (state is AccountSwitchIdle && toCarol == null) {
          toCarol = switchNotifierOf().switchTo(carol, view);
        }
      });

      final toBob = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.complete();
      await toBob;

      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'loadAccount(bob-account-id, 1)',
        'unblockInput',
        'blockInput',
        'keepSelectionAndSearch',
        'loadAccount(carol-account-id, 2)',
      ]);
      view.loadings.last.complete();
      expect(await toCarol, const AccountSwitched());
    });

    test('when unblocking input throws: still returns the result and ends the switch', () async {
      view.errorThrownByUnblockInput = StateError('cannot unblock input');

      final switching = switchNotifierOf().switchTo(bob, view);
      view.loadings.single.complete();

      expect(await switching, const AccountSwitched());
      expect(shownAccountOf(), ActiveAccount.delegated(session, bob));
      expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 1));
    });

    test('a cancel asked while input is being blocked cancels the switch', () async {
      view.onBlockInput = () => switchNotifierOf().cancel();

      final result = await switchNotifierOf().switchTo(bob, view);

      expect(result, const AccountSwitchCancelled());
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(view.calls, [
        'blockInput',
        'keepSelectionAndSearch',
        'restoreSelectionAndSearch',
        'catchUpAccount(${alice.id.value}, 2)',
        'unblockInput',
      ]);
    });
  });

  group('logout', () {
    test(
      'same user signing in after logout starts on mine with a new attempt, not the previous delegated account',
      () async {
        await showBobMailbox();

        switchNotifierOf().endSession();
        final signInSession = DelegationFixtures.session(state: 'state-2');
        activeAccountNotifierOf().applySession(signInSession);

        expect(shownAccountOf(), ActiveAccount.personal(signInSession));
        expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
      },
    );

    test(
      'during a switch: does not roll back or catch up, and late load results keep a stale attempt id',
      () async {
        final switching = switchNotifierOf().switchTo(bob, view);

        switchNotifierOf().endSession();
        expect(switchStateOf(), const AccountSwitchEndingSession(2));
        final result = await switching;
        view.loadings.single.complete();
        await pumpEventQueue();

        expect(result, const AccountSwitchCancelled());
        expect(shownAccountOf(), isNull);
        expect(switchStateOf(), const AccountSwitchIdle(lastAttemptId: 2));
        expect(view.calls, isNot(contains('restoreSelectionAndSearch')));
        expect(
          view.calls.where((call) => call.startsWith('catchUpAccount')),
          isEmpty,
        );
      },
    );
  });

  group('cancel', () {
    test('does nothing when no switch runs', () {
      switchNotifierOf().cancel();

      expect(switchStateOf(), const AccountSwitchIdle());
      expect(shownAccountOf(), ActiveAccount.personal(session));
    });

    test('a second cancel of the same switch does nothing more', () async {
      final switching = switchNotifierOf().switchTo(bob, view);

      switchNotifierOf().cancel();
      switchNotifierOf().cancel();

      expect(await switching, const AccountSwitchCancelled());
    });
  });
}

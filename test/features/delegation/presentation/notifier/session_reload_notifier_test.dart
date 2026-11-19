import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/urgent_exception_handler.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/delegation_ended_handler.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/session_reload.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/session_reload_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_ended_handlers_provider.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/delegation_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

class _RecordingSwitchView implements AccountSwitchView {
  final List<String> calls = [];
  int openComposerCount = 0;
  bool failsCloseComposers = false;
  Future<void>? heldClose;

  @override
  bool hasOpenComposer = false;

  @override
  Future<int> closeComposers() async {
    calls.add('closeComposers');
    if (failsCloseComposers) throw StateError('composers');
    await heldClose;
    final closedCount = openComposerCount;
    openComposerCount = 0;
    return closedCount;
  }

  @override
  void blockInput() => calls.add('blockInput');

  @override
  void unblockInput() => calls.add('unblockInput');

  bool failsClearSelection = false;

  @override
  void clearSelectionAndSearch() {
    if (failsClearSelection) throw StateError('selection');
    calls.add('clearSelectionAndSearch');
  }

  @override
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId) async {
    calls.add('loadAccount(${account.accountId.id.value})');
  }

  @override
  void catchUpAccount(ActiveAccount account, int switchAttemptId) {
    calls.add('catchUpAccount(${account.accountId.id.value})');
  }
}

void main() {
  final bob = DelegationFixtures.bobAccountId;
  final alice = DelegationFixtures.aliceAccountId;

  late ProviderContainer container;
  late FakeGetSessionInteractor getSessionInteractor;
  late _RecordingSwitchView view;
  late Session session;
  late DateTime now;
  late bool dashboardIsOpen;
  late bool dashboardLookupFails;
  late List<DelegationEndedHandler> handlers;
  AccountSwitchView? dashboardViewOverride;

  SessionReloadNotifier notifier() => container.read(sessionReloadProvider.notifier);
  ActiveAccount? shownAccountOf() => container.read(activeAccountProvider);

  void serverAnswers(Session answer, {bool fromCache = false}) {
    getSessionInteractor.result = Right(GetSessionSuccess(answer, fromCache: fromCache));
  }

  void turnDelegationOff() => container
      .read(localSettingsProvider.notifier)
      .update(PreferencesSetting([DelegationConfig(isEnabled: false)]));

  Future<void> showBobMailbox() async {
    await container.read(accountSwitchProvider.notifier).switchTo(bob, view);
    view.calls.clear();
  }

  setUp(() {
    getSessionInteractor = FakeGetSessionInteractor();
    Get.put<GetSessionInteractor>(getSessionInteractor);
    view = _RecordingSwitchView();
    session = DelegationFixtures.session();
    now = DateTime(2026, 1, 1, 9);
    dashboardIsOpen = true;
    dashboardLookupFails = false;
    handlers = [];
    dashboardViewOverride = null;
    container = ProviderContainer(overrides: [
      sessionReloadClockProvider.overrideWithValue(() => now),
      delegationEndedHandlersProvider.overrideWith((ref) => handlers),
      dashboardAccountSwitchViewProvider.overrideWithValue(() {
        if (dashboardLookupFails) throw StateError('dashboard');
        return dashboardIsOpen ? dashboardViewOverride ?? view : null;
      }),
    ]);
    DelegationFixtures.turnDelegationOn(container);
    container.read(activeAccountProvider.notifier).applySession(session);
    serverAnswers(DelegationFixtures.session(state: 'state-2'));
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group('reload', () {
    test('applies a fresh session to the shown account and exposes it', () async {
      final fresh = DelegationFixtures.session(state: 'state-2', listsCarol: false);
      serverAnswers(fresh);

      final reloaded = await notifier().reload();

      expect(reloaded, fresh);
      expect(shownAccountOf(), ActiveAccount.personal(fresh));
      expect(container.read(sessionReloadProvider), SessionReload(fresh));
    });

    test('SHOULD NOT apply a session read from cache', () async {
      serverAnswers(DelegationFixtures.session(state: 'state-2', listsBob: false), fromCache: true);

      final reloaded = await notifier().reload();

      expect(reloaded, isNull);
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(container.read(sessionReloadProvider), isNull);
    });

    test('SHOULD NOT let the session read fall back to the cache, so an expired login still signs out', () async {
      await notifier().reload();

      expect(getSessionInteractor.fallbackToCacheArgs, [false]);
    });

    test('SHOULD NOT apply a re-read that completes after sign-out', () async {
      getSessionInteractor.holdsReads = true;
      final reload = notifier().reload();
      await pumpEventQueue();
      container.read(activeAccountProvider.notifier).clear();
      getSessionInteractor.pendingReads.single.complete(Right(GetSessionSuccess(session)));

      expect(await reload, isNull);
      expect(shownAccountOf(), isNull);
      expect(container.read(sessionReloadProvider), isNull);
    });

    test('SHOULD NOT apply a re-read of another user', () async {
      serverAnswers(DelegationFixtures.session(username: DelegationFixtures.carolAddress));

      expect(await notifier().reload(), isNull);
      expect(shownAccountOf(), ActiveAccount.personal(session));
    });

    test('keeps one read in flight and runs one more after it for every call made meanwhile', () async {
      getSessionInteractor.holdsReads = true;
      final first = notifier().reload();
      final second = notifier().reload();
      final third = notifier().reload();
      await pumpEventQueue();
      expect(getSessionInteractor.pendingReads.length, 1);

      final older = DelegationFixtures.session(state: 'state-2');
      final newer = DelegationFixtures.session(state: 'state-3');
      getSessionInteractor.pendingReads[0].complete(Right(GetSessionSuccess(older)));
      expect(await first, older);
      await pumpEventQueue();
      expect(getSessionInteractor.pendingReads.length, 2);
      getSessionInteractor.pendingReads[1].complete(Right(GetSessionSuccess(newer)));

      expect(await second, newer);
      expect(await third, newer);
      expect(getSessionInteractor.calls, 2);
    });

    test('still runs the read queued behind a read that fails', () async {
      await showBobMailbox();
      getSessionInteractor.holdsReads = true;
      final failing = notifier().reload();
      final queued = notifier().reload();
      await pumpEventQueue();
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      dashboardLookupFails = true;
      getSessionInteractor.pendingReads[0].complete(Right(GetSessionSuccess(withoutBob)));
      expect(await failing, isNull);
      expect(container.read(activeAccountProvider)?.accountId, bob);
      dashboardLookupFails = false;
      await pumpEventQueue();

      expect(getSessionInteractor.pendingReads.length, 2);
      getSessionInteractor.pendingReads[1].complete(Right(GetSessionSuccess(withoutBob)));
      expect(await queued, withoutBob);
    });
  });

  group('failure', () {
    late _UrgentExceptionHandler urgentHandler;

    setUp(() {
      urgentHandler = _UrgentExceptionHandler();
      Get.put<UrgentExceptionHandler>(urgentHandler);
    });

    test('SHOULD NOT route a re-read that fails offline to the urgent handler', () async {
      getSessionInteractor.result = Left(GetSessionFailure(const ConnectionError()));

      expect(await notifier().reload(), isNull);

      expect(urgentHandler.handled, isEmpty);
    });

    test('SHOULD NOT route a re-read that fails without network to the urgent handler', () async {
      getSessionInteractor.result = Left(GetSessionFailure(const NoNetworkError()));

      expect(await notifier().reload(), isNull);

      expect(urgentHandler.handled, isEmpty);
    });

    test('routes a re-read that fails on an expired login to the urgent handler', () async {
      final failure = GetSessionFailure(const BadCredentialsException());
      getSessionInteractor.result = Left(failure);

      expect(await notifier().reload(), isNull);

      expect(urgentHandler.handled, [failure]);
      expect(shownAccountOf(), ActiveAccount.personal(session));
    });

    test('still runs the read queued behind a read whose urgent routing throws', () async {
      urgentHandler.throwsOnHandle = true;
      getSessionInteractor.holdsReads = true;
      final failing = notifier().reload();
      final queued = notifier().reload();
      await pumpEventQueue();
      getSessionInteractor.pendingReads[0].complete(Left(GetSessionFailure(const BadCredentialsException())));
      expect(await failing, isNull);
      await pumpEventQueue();

      expect(getSessionInteractor.pendingReads.length, 2);
      final fresh = DelegationFixtures.session(state: 'state-2');
      getSessionInteractor.pendingReads[1].complete(Right(GetSessionSuccess(fresh)));
      expect(await queued, fresh);
    });
  });

  group('reloadOnResume', () {
    test('reads at most once a minute', () async {
      notifier().reloadOnResume();
      await pumpEventQueue();
      now = now.add(const Duration(seconds: 59));
      notifier().reloadOnResume();
      await pumpEventQueue();
      expect(getSessionInteractor.calls, 1);

      now = now.add(const Duration(seconds: 1));
      notifier().reloadOnResume();
      await pumpEventQueue();
      expect(getSessionInteractor.calls, 2);
    });

    test('SHOULD NOT throw when applying the re-read fails', () async {
      await showBobMailbox();
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      getSessionInteractor.result = Right(GetSessionSuccess(withoutBob));
      dashboardLookupFails = true;

      notifier().reloadOnResume();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 1);
      expect(container.read(sessionReloadProvider), isNull);
      expect(container.read(activeAccountProvider)?.accountId, bob);
    });

    test('SHOULD NOT read while delegation is off', () async {
      turnDelegationOff();

      notifier().reloadOnResume();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 0);
    });
  });

  group('reloadOnAccountNotFound', () {
    test('reads at once while a delegated mailbox is shown', () async {
      await showBobMailbox();

      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 1);
    });

    test('SHOULD NOT read while my own mailbox is shown', () async {
      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 0);
    });

    test('SHOULD NOT read while delegation is off', () async {
      await showBobMailbox();
      turnDelegationOff();

      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 0);
    });

    test('waits for the next resume once a re-read still lists the shown mailbox', () async {
      await showBobMailbox();
      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();
      expect(getSessionInteractor.calls, 1);

      notifier().reloadOnResume();
      await pumpEventQueue();
      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();
      expect(getSessionInteractor.calls, 3);
    });

    test('SHOULD NOT wait for the next resume when the re-read answers after a resume', () async {
      await showBobMailbox();
      notifier().reloadOnResume();
      await pumpEventQueue();
      getSessionInteractor.holdsReads = true;
      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();
      now = now.add(const Duration(seconds: 10));
      notifier().reloadOnResume();
      getSessionInteractor.pendingReads.single.complete(Right(GetSessionSuccess(session)));
      await pumpEventQueue();

      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 3);
    });
  });

  group('rebuild', () {
    test('reads at once after a rebuild while a read of the ended session is held', () async {
      getSessionInteractor.holdsReads = true;
      unawaited(notifier().reload());
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      unawaited(notifier().reload());
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 2);
    });

    test('SHOULD NOT start a read queued before a rebuild', () async {
      getSessionInteractor.holdsReads = true;
      unawaited(notifier().reload());
      final queuedBeforeRebuild = notifier().reload();
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      unawaited(notifier().reload());
      await pumpEventQueue();
      getSessionInteractor.pendingReads.first.complete(Right(GetSessionSuccess(session)));

      expect(await queuedBeforeRebuild, isNull);
      expect(getSessionInteractor.pendingReads.length, 2);
    });

    test('keeps the read queued after a rebuild when a read queued before it ends', () async {
      getSessionInteractor.holdsReads = true;
      unawaited(notifier().reload());
      unawaited(notifier().reload());
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      unawaited(notifier().reload());
      unawaited(notifier().reload());
      await pumpEventQueue();
      getSessionInteractor.pendingReads[0].complete(Right(GetSessionSuccess(session)));
      await pumpEventQueue();
      expect(getSessionInteractor.pendingReads.length, 2);

      getSessionInteractor.pendingReads[1].complete(Right(GetSessionSuccess(session)));
      await pumpEventQueue();
      expect(getSessionInteractor.pendingReads.length, 3);
    });

    test('SHOULD NOT apply a read of the ended session that completes after a rebuild', () async {
      getSessionInteractor.holdsReads = true;
      final staleReload = notifier().reload();
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      notifier();
      getSessionInteractor.pendingReads.single.complete(
        Right(GetSessionSuccess(DelegationFixtures.session(state: 'state-2', listsCarol: false))),
      );

      expect(await staleReload, isNull);
      expect(shownAccountOf(), ActiveAccount.personal(session));
      expect(container.read(sessionReloadProvider), isNull);
    });

    test('reads on resume at once after a rebuild', () async {
      notifier().reloadOnResume();
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      notifier().reloadOnResume();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 2);
    });

    test('reads again on account not found after a rebuild', () async {
      await showBobMailbox();
      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      notifier().reloadOnAccountNotFound();
      await pumpEventQueue();

      expect(getSessionInteractor.calls, 2);
    });
  });

  group('revocation', () {
    test('closes the composers, shows my mailbox and reports the revoked owner', () async {
      await showBobMailbox();
      view.hasOpenComposer = true;
      view.openComposerCount = 2;
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      serverAnswers(withoutBob);

      await notifier().reload();

      expect(shownAccountOf(), ActiveAccount.personal(withoutBob));
      expect(view.calls, [
        'closeComposers',
        'blockInput',
        'clearSelectionAndSearch',
        'loadAccount(${alice.id.value})',
        'unblockInput',
      ]);
      expect(
        container.read(sessionReloadProvider),
        SessionReload(
          withoutBob,
          revokedOwnerEmailAddress: DelegationFixtures.bobAddress,
          lostComposerCount: 2,
        ),
      );
    });

    test('SHOULD NOT report a revocation while the shown mailbox is still listed', () async {
      await showBobMailbox();
      final stillListsBob = DelegationFixtures.session(state: 'state-2');
      serverAnswers(stillListsBob);

      await notifier().reload();

      expect(shownAccountOf(), ActiveAccount.delegated(stillListsBob, bob));
      expect(view.calls, isEmpty);
      expect(container.read(sessionReloadProvider), SessionReload(stillListsBob));
    });

    test('SHOULD NOT leave the shown mailbox for a re-read of another user', () async {
      await showBobMailbox();
      view.openComposerCount = 1;
      serverAnswers(DelegationFixtures.session(username: DelegationFixtures.carolAddress, listsBob: false));

      await notifier().reload();

      expect(shownAccountOf(), ActiveAccount.delegated(session, bob));
      expect(view.calls, isEmpty);
      expect(view.openComposerCount, 1);
    });

    test('cancels a switch in flight to the revoked mailbox without a second switch', () async {
      final loading = Completer<void>();
      final slowView = _HeldLoadSwitchView(loading.future);
      final switching = container.read(accountSwitchProvider.notifier).switchTo(bob, slowView);
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      serverAnswers(withoutBob);

      await notifier().reload();
      await switching;

      expect(shownAccountOf(), ActiveAccount.personal(withoutBob));
      expect(view.calls, isEmpty);
      expect(container.read(sessionReloadProvider), SessionReload(withoutBob));
    });

    test('reports that my mailbox could not be shown when leaving the revoked mailbox fails', () async {
      await showBobMailbox();
      view.failsClearSelection = true;
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      serverAnswers(withoutBob);

      await notifier().reload();

      expect(view.calls, ['closeComposers', 'blockInput', 'catchUpAccount(${alice.id.value})', 'unblockInput']);
      expect(
        container.read(sessionReloadProvider),
        SessionReload(
          withoutBob,
          revokedOwnerEmailAddress: DelegationFixtures.bobAddress,
          couldNotReturnToMine: true,
        ),
      );
    });

    test('reports that my mailbox could not be shown when closing the composers fails', () async {
      await showBobMailbox();
      view.failsCloseComposers = true;
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      serverAnswers(withoutBob);

      expect(await notifier().reload(), withoutBob);

      expect(shownAccountOf(), ActiveAccount.personal(withoutBob));
      expect(view.calls, ['closeComposers']);
      expect(
        container.read(sessionReloadProvider),
        SessionReload(
          withoutBob,
          revokedOwnerEmailAddress: DelegationFixtures.bobAddress,
          couldNotReturnToMine: true,
        ),
      );
    });

    test('SHOULD NOT switch the account after a sign-out while the composers close', () async {
      await showBobMailbox();
      final close = Completer<void>();
      view.heldClose = close.future;
      serverAnswers(DelegationFixtures.session(state: 'state-2', listsBob: false));
      final reload = notifier().reload();
      await pumpEventQueue();

      container.invalidate(sessionReloadProvider);
      notifier();
      close.complete();

      expect(await reload, isNull);
      expect(view.calls, ['closeComposers']);
      expect(shownAccountOf()?.accountId, bob);
    });

    test('SHOULD NOT leave the mailbox I pick while the composers of the revoked one close', () async {
      final carol = DelegationFixtures.carolAccountId;
      await showBobMailbox();
      view.openComposerCount = 1;
      final close = Completer<void>();
      view.heldClose = close.future;
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      serverAnswers(withoutBob);
      final reload = notifier().reload();
      await pumpEventQueue();

      await container.read(accountSwitchProvider.notifier).switchTo(carol, view, closesOpenComposer: true);
      view.calls.clear();
      close.complete();

      expect(await reload, withoutBob);
      expect(view.calls, isEmpty);
      expect(shownAccountOf(), ActiveAccount.delegated(withoutBob, carol));
      expect(
        container.read(sessionReloadProvider),
        SessionReload(withoutBob, revokedOwnerEmailAddress: DelegationFixtures.bobAddress, lostComposerCount: 1),
      );
    });

    group('with a handler keeping two composers', () {
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      late _RecordingHandler keeper;

      setUp(() async {
        await showBobMailbox();
        view.openComposerCount = 2;
        keeper = _RecordingHandler(
          'keeper',
          view.calls,
          shownAccountOf,
          keptComposerCount: 2,
          droppedAttachmentNames: ['notes.pdf', 'logo.png'],
        );
        handlers = [keeper];
        serverAnswers(withoutBob);
      });

      test('reopens them in my mailbox after the switch and reports what was kept', () async {
        await notifier().reload();

        expect(view.calls, [
          'beforeLeave(keeper)',
          'closeComposers',
          'blockInput',
          'clearSelectionAndSearch',
          'loadAccount(${alice.id.value})',
          'unblockInput',
          'afterLeave(keeper) in ${alice.id.value}',
        ]);
        expect(
          container.read(sessionReloadProvider),
          SessionReload(
            withoutBob,
            revokedOwnerEmailAddress: DelegationFixtures.bobAddress,
            keptComposerCount: 2,
            droppedAttachmentNames: const ['notes.pdf', 'logo.png'],
          ),
        );
      });

      test('counts as lost only the open composers no handler kept', () async {
        view.openComposerCount = 3;

        await notifier().reload();

        expect(container.read(sessionReloadProvider)?.lostComposerCount, 1);
        expect(container.read(sessionReloadProvider)?.keptComposerCount, 2);
      });

      test('SHOULD NOT report a negative loss when fewer composers closed than were kept', () async {
        view.openComposerCount = 1;

        await notifier().reload();

        expect(container.read(sessionReloadProvider)?.lostComposerCount, 0);
      });

      test('reopens them in my mailbox shown by the fallback when the switch fails', () async {
        view.failsClearSelection = true;

        await notifier().reload();

        expect(shownAccountOf(), ActiveAccount.personal(withoutBob));
        expect(view.calls.last, 'afterLeave(keeper) in ${alice.id.value}');
        expect(
          container.read(sessionReloadProvider),
          SessionReload(
            withoutBob,
            revokedOwnerEmailAddress: DelegationFixtures.bobAddress,
            keptComposerCount: 2,
            droppedAttachmentNames: const ['notes.pdf', 'logo.png'],
            couldNotReturnToMine: true,
          ),
        );
      });

      test('SHOULD NOT reopen them in a mailbox I pick while the composers close', () async {
        final close = Completer<void>();
        view.heldClose = close.future;
        final reload = notifier().reload();
        await pumpEventQueue();

        await container
            .read(accountSwitchProvider.notifier)
            .switchTo(DelegationFixtures.carolAccountId, view, closesOpenComposer: true);
        view.calls.clear();
        close.complete();
        await reload;

        expect(view.calls, isEmpty);
        expect(container.read(sessionReloadProvider)?.lostComposerCount, 2);
        expect(container.read(sessionReloadProvider)?.keptComposerCount, 0);
      });

      test('SHOULD NOT reopen them after a sign-out during the switch', () async {
        final load = Completer<void>();
        final heldView = _HeldLoadSwitchView(load.future)..openComposerCount = 2;
        dashboardViewOverride = heldView;
        final reload = notifier().reload();
        await pumpEventQueue();

        container.invalidate(sessionReloadProvider);
        notifier();
        load.complete();

        expect(await reload, isNull);
        expect(view.calls, isNot(contains(startsWith('afterLeave'))));
      });

      test('a failing handler stops neither the next one nor the switch', () async {
        handlers = [_RecordingHandler('broken', view.calls, shownAccountOf, failsBeforeLeave: true), keeper];

        await notifier().reload();

        expect(shownAccountOf(), ActiveAccount.personal(withoutBob));
        expect(view.calls.first, 'beforeLeave(broken)');
        expect(view.calls[1], 'beforeLeave(keeper)');
        expect(view.calls.last, 'afterLeave(keeper) in ${alice.id.value}');
        expect(container.read(sessionReloadProvider)?.keptComposerCount, 2);
      });

      test('counts the composers of a failed reopen as lost and still runs the next reopen', () async {
        final failing = _RecordingHandler(
          'failing',
          view.calls,
          shownAccountOf,
          keptComposerCount: 1,
          droppedAttachmentNames: ['plan.txt'],
          failsAfterLeave: true,
        );
        handlers = [failing, keeper];
        view.openComposerCount = 3;

        await notifier().reload();

        expect(view.calls.last, 'afterLeave(keeper) in ${alice.id.value}');
        expect(
          container.read(sessionReloadProvider),
          SessionReload(
            withoutBob,
            revokedOwnerEmailAddress: DelegationFixtures.bobAddress,
            lostComposerCount: 1,
            keptComposerCount: 2,
            droppedAttachmentNames: const ['notes.pdf', 'logo.png'],
          ),
        );
      });
    });

    test('still shows my mailbox once the dashboard is gone', () async {
      await showBobMailbox();
      dashboardIsOpen = false;
      final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);
      serverAnswers(withoutBob);

      await notifier().reload();

      expect(shownAccountOf(), ActiveAccount.personal(withoutBob));
      expect(view.calls, isEmpty);
    });
  });
}

class _UrgentExceptionHandler implements UrgentExceptionHandler {
  final List<Object?> handled = [];
  bool throwsOnHandle = false;

  @override
  bool validateUrgentException(dynamic exception) => true;

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) {
    if (throwsOnHandle) throw StateError('urgent');
    handled.add(failure ?? exception);
  }
}

typedef _ShownAccountReader = ActiveAccount? Function();

class _RecordingHandler implements DelegationEndedHandler {
  final String name;
  final List<String> calls;
  final _ShownAccountReader shownAccountOf;
  final int keptComposerCount;
  final List<String> droppedAttachmentNames;
  final bool failsBeforeLeave;
  final bool failsAfterLeave;

  _RecordingHandler(
    this.name,
    this.calls,
    this.shownAccountOf, {
    this.keptComposerCount = 0,
    this.droppedAttachmentNames = const [],
    this.failsBeforeLeave = false,
    this.failsAfterLeave = false,
  });

  @override
  Future<DelegationEndedHandling> beforeLeave() async {
    calls.add('beforeLeave($name)');
    if (failsBeforeLeave) throw StateError(name);
    return DelegationEndedHandling(
      keptComposerCount: keptComposerCount,
      droppedAttachmentNames: droppedAttachmentNames,
      afterLeave: () async {
        if (failsAfterLeave) throw StateError(name);
        calls.add('afterLeave($name) in ${shownAccountOf()?.accountId.id.value}');
      },
    );
  }
}

class _HeldLoadSwitchView extends _RecordingSwitchView {
  final Future<void> _load;

  _HeldLoadSwitchView(this._load);

  @override
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId) => _load;
}

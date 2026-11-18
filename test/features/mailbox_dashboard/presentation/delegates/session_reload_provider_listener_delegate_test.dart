import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/session_reload.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/session_reload_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/session_reload_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/riverpod_widgets/mailbox_dashboard_provider_listener_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';

import '../../../../fixtures/delegation_fixtures.dart';

InternalFinalCallback<void> _noopCallback() => InternalFinalCallback<void>(callback: () {});

class _Dashboard extends Mock implements MailboxDashBoardController {
  @override
  Session? sessionCurrent;

  @override
  InternalFinalCallback<void> get onStart => _noopCallback();

  @override
  InternalFinalCallback<void> get onDelete => _noopCallback();
}

class _CleanupInteractor implements CleanupEndedDelegationsInteractor {
  int lostCount = 0;
  final List<Session> cleanedSessions = [];

  @override
  Future<Either<Failure, Success>> execute({required Session session, required bool fromCache}) async {
    cleanedSessions.add(session);
    return Right(CleanupEndedDelegationsSuccess(deletedAccountIds: const [], lostCount: lostCount));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingToast implements AppToast {
  final List<String> warnings = [];
  final List<String> errors = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final messages = switch (invocation.memberName) {
      #showToastWarningMessage => warnings,
      #showToastErrorMessage => errors,
      _ => null,
    };
    if (messages == null) return super.noSuchMethod(invocation);
    messages.add(invocation.positionalArguments[1] as String);
  }
}

class _SessionReloads extends SessionReloadNotifier {
  @override
  SessionReload? build() => null;

  void emit(SessionReload reload) => state = reload;
}

void main() {
  late _Dashboard dashboard;
  late _CleanupInteractor cleanup;
  late _RecordingToast toast;
  late int reenablePushCount;
  late Session session;

  setUp(() {
    Get.testMode = true;
    session = DelegationFixtures.session();
    dashboard = _Dashboard()..sessionCurrent = session;
    cleanup = _CleanupInteractor();
    toast = _RecordingToast();
    reenablePushCount = 0;
    Get.put<MailboxDashBoardController>(dashboard);
    Get.put<CleanupEndedDelegationsInteractor>(cleanup);
    Get.put<AppToast>(toast);
  });

  tearDown(Get.reset);

  Future<_SessionReloads> pumpDelegate(WidgetTester tester, {bool showsDelegate = true}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionReloadProvider.overrideWith(_SessionReloads.new)],
        child: GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: showsDelegate
              ? MailboxDashboardProviderListenerWidget(
                  delegateFactories: [
                    () => SessionReloadProviderListenerDelegate(reenablePush: () => reenablePushCount++),
                  ],
                  child: const SizedBox(),
                )
              : const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(tester.element(find.byType(SizedBox)));
    return container.read(sessionReloadProvider.notifier) as _SessionReloads;
  }

  AppLocalizations l10nOf(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(SizedBox)));

  Future<void> emit(WidgetTester tester, _SessionReloads reloads, SessionReload reload) async {
    reloads.emit(reload);
    await tester.pumpAndSettle();
  }

  testWidgets('applies a re-read listing the same accounts without re-enabling push or a toast', (tester) async {
    final reloads = await pumpDelegate(tester);
    final fresh = DelegationFixtures.session(state: 'state-2');

    await emit(tester, reloads, SessionReload(fresh));

    expect(dashboard.sessionCurrent, fresh);
    expect(reenablePushCount, 0);
    expect(cleanup.cleanedSessions, [fresh]);
    expect(toast.warnings, isEmpty);
    expect(toast.errors, isEmpty);
  });

  testWidgets('re-enables push once when the re-read lists other accounts', (tester) async {
    final reloads = await pumpDelegate(tester);

    await emit(tester, reloads, SessionReload(DelegationFixtures.session(state: 'state-2', listsCarol: false)));

    expect(reenablePushCount, 1);
  });

  testWidgets('warns about the lost items of an ended delegation that was not shown', (tester) async {
    final reloads = await pumpDelegate(tester);
    cleanup.lostCount = 2;

    await emit(tester, reloads, SessionReload(DelegationFixtures.session(state: 'state-2', listsCarol: false)));

    expect(toast.warnings, [l10nOf(tester).endedDelegationLostItems(2)]);
  });

  testWidgets('warns that the access ended when the revoked mailbox lost nothing', (tester) async {
    final reloads = await pumpDelegate(tester);
    final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);

    await emit(tester, reloads, SessionReload(withoutBob, revokedOwnerEmailAddress: DelegationFixtures.bobAddress));

    expect(toast.warnings, [l10nOf(tester).delegatedMailboxAccessEnded(DelegationFixtures.bobAddress)]);
    expect(toast.errors, isEmpty);
  });

  testWidgets('warns once with the closed composers and stored items of the revoked mailbox', (tester) async {
    final reloads = await pumpDelegate(tester);
    cleanup.lostCount = 2;
    final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);

    await emit(
      tester,
      reloads,
      SessionReload(withoutBob, revokedOwnerEmailAddress: DelegationFixtures.bobAddress, closedComposerCount: 1),
    );

    expect(toast.warnings, [l10nOf(tester).endedDelegationLostItems(3)]);
  });

  testWidgets('shows only the error when my mailbox could not be shown after a revocation', (tester) async {
    final reloads = await pumpDelegate(tester);
    cleanup.lostCount = 2;
    final withoutBob = DelegationFixtures.session(state: 'state-2', listsBob: false);

    await emit(
      tester,
      reloads,
      SessionReload(withoutBob, revokedOwnerEmailAddress: DelegationFixtures.bobAddress, couldNotReturnToMine: true),
    );

    expect(toast.errors, [l10nOf(tester).couldNotReturnToYourMailbox]);
    expect(toast.warnings, isEmpty);
    expect(cleanup.cleanedSessions, [withoutBob]);
  });

  testWidgets('SHOULD NOT react once the dashboard is gone', (tester) async {
    final reloads = await pumpDelegate(tester);
    Get.delete<MailboxDashBoardController>();

    await emit(tester, reloads, SessionReload(DelegationFixtures.session(state: 'state-2', listsBob: false), revokedOwnerEmailAddress: DelegationFixtures.bobAddress));

    expect(reenablePushCount, 0);
    expect(cleanup.cleanedSessions, isEmpty);
    expect(toast.warnings, isEmpty);
  });

  testWidgets('SHOULD NOT react after the delegate is disposed', (tester) async {
    final reloads = await pumpDelegate(tester);
    await pumpDelegate(tester, showsDelegate: false);

    reloads.emit(SessionReload(DelegationFixtures.session(state: 'state-2', listsBob: false)));
    await tester.pump();

    expect(dashboard.sessionCurrent, session);
    expect(reenablePushCount, 0);
    expect(cleanup.cleanedSessions, isEmpty);
  });
}

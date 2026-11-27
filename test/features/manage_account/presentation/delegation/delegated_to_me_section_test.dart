import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegated_account_providers.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegated_to_me_section.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart';

import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/recording_app_toast.dart';

void main() {
  final bobDelegation = DelegatedAccount(id: Id('bob-delegation'), username: DelegationFixtures.bobAddress);
  final l10n = AppLocalizations();

  late ProviderContainer container;
  late FakeDelegatedAccountRepository repository;
  late FakeGetSessionInteractor getSessionInteractor;
  late RecordingAppToast appToast;
  late Session reReadSession;
  late List<Session> reloadedSessions;

  setUp(() {
    repository = FakeDelegatedAccountRepository();
    // Lists only Bob, like the With me list most tests load.
    reReadSession = DelegationFixtures.session(listsBob: false, listsCarol: false);
    reloadedSessions = [];
    getSessionInteractor = FakeGetSessionInteractor()..result = Right(GetSessionSuccess(reReadSession));
    appToast = RecordingAppToast();
    Get.put<GetSessionInteractor>(getSessionInteractor);
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
    container = ProviderContainer(overrides: [
      delegatedAccountRepositoryProvider.overrideWithValue(repository),
      appToastProvider.overrideWithValue(appToast.toast),
    ]);
    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session(listsCarol: false));
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService.supportedLocales,
        locale: LocalizationService.defaultLocale,
        home: Scaffold(
          body: DelegatedToMeSection(
            session: DelegationFixtures.session(listsCarol: false),
            onSessionReloaded: reloadedSessions.add,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);
  }

  Future<void> completeLoad(WidgetTester tester, List<DelegatedAccount> accounts) async {
    repository.pendingLoads.last.complete(accounts);
    await tester.pumpAndSettle();
  }

  Future<void> confirmRemoval(WidgetTester tester) async {
    await tester.tap(find.byKey(LinagoraPersonTile.actionKeyFor(bobDelegation.username)));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(ConfirmationDialogBuilder),
      matching: find.text(l10n.removeAccess),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('should refresh the switcher when the list names a mailbox the session does not list', (tester) async {
    final freshSession = DelegationFixtures.session(state: 'state-2');
    getSessionInteractor.result = Right(GetSessionSuccess(freshSession));
    await pumpSection(tester);
    await completeLoad(tester, [bobDelegation, DelegatedAccount(id: Id('carol-delegation'), username: DelegationFixtures.carolAddress)]);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(reloadedSessions, [freshSession]);
  });

  testWidgets('should show a spinner while the list loads', (tester) async {
    await pumpSection(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l10n.mailboxesDelegatedToMe), findsNothing);
    expect(find.text('0'), findsNothing);
    await completeLoad(tester, []);
  });

  testWidgets('should show the empty card when nothing is delegated to me', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, []);

    expect(find.byKey(const ValueKey(UiKeys.delegatedToMeEmptyCard)), findsOneWidget);
    expect(find.text(l10n.noMailboxesSharedWithYou), findsOneWidget);
    expect(find.text(l10n.mailboxesDelegatedToMe), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('should list each delegated mailbox with its count', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bobDelegation]);

    expect(find.text(l10n.mailboxesSharedWithMe), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text(l10n.mailboxesDelegatedToMe), findsNothing);
    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
  });

  testWidgets('should reload the list when retry is tapped after a failure', (tester) async {
    await pumpSection(tester);
    repository.pendingLoads.last.completeError(Exception('boom'));
    await tester.pumpAndSettle();
    expect(find.text(l10n.retry), findsOneWidget);
    expect(find.text(l10n.mailboxesDelegatedToMe), findsNothing);

    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    await tester.runAsync(untilRepositoryCalled);
    await completeLoad(tester, [bobDelegation]);

    expect(repository.pendingLoads, hasLength(2));
    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
  });

  testWidgets('should remove the mailbox once removal is confirmed', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bobDelegation]);

    await confirmRemoval(tester);

    expect(repository.removedIds, [bobDelegation.id]);
    expect(find.byKey(const ValueKey(UiKeys.delegatedToMeEmptyCard)), findsOneWidget);
    expect(appToast.errorMessages, isEmpty);
    expect(reloadedSessions, [reReadSession]);
  });

  testWidgets('should keep the mailbox and show a toast when removal fails', (tester) async {
    await pumpSection(tester);
    await completeLoad(tester, [bobDelegation]);
    repository.removeError = Exception('boom');

    await confirmRemoval(tester);

    expect(find.text(DelegationFixtures.bobAddress), findsOneWidget);
    expect(appToast.errorMessages, [l10n.couldNotRemoveYourAccess]);
    expect(reloadedSessions, isEmpty);
  });
}

import 'dart:async';

import 'package:core/utils/platform_info.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:flutter/widgets.dart' hide State;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:labels/labels.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:rxdart/subjects.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_default_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart' show appToastProvider;
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import 'mailbox_dashboard_controller_test_harness.dart';

class _FakeSwitchView implements AccountSwitchView {
  @override
  bool get hasOpenComposer => false;

  @override
  void blockInput() {}

  @override
  void unblockInput() {}

  @override
  void clearSelectionAndSearch() {}

  @override
  Future<void> loadAccount(account, int switchAttemptId) async {}

  @override
  void catchUpAccount(account, int switchAttemptId) {}
}

/// Shows [shownOnSwitch] through [source] and answers [result], once [pending] completes when set.
class _ScriptedSwitchNotifier extends AccountSwitchNotifier {
  final FakeActiveAccountSource source;
  final List<AccountId> switchToCalls = [];
  AccountSwitchResult result = const AccountSwitched();
  AccountId? shownOnSwitch;
  Completer<void>? pending;

  _ScriptedSwitchNotifier(this.source);

  @override
  AccountSwitchState build() => const AccountSwitchIdle();

  @override
  Future<AccountSwitchResult> switchTo(AccountId targetAccountId, AccountSwitchView view) async {
    switchToCalls.add(targetAccountId);
    await pending?.future;
    if (shownOnSwitch != null) source.show(shownOnSwitch!);
    return result;
  }
}

/// Ends after the start URL is read and after its folder tree is built, as a server answer does in the app.
Stream<Either<Failure, Success>> _loadedFolders() async* {
  await Future<void>(() {});
  yield Right(GetAllMailboxSuccess(
    mailboxList: [MailboxFixtures.inboxMailbox.toPresentationMailbox()],
    currentMailboxState: State('mailbox-state'),
  ));
  await Future<void>(() {});
}

void main() {
  setUpMailboxDashboardControllerTest();

  final urlEmailId = EmailId(Id('url-email'));
  late FakeActiveAccountSource source;
  late _ScriptedSwitchNotifier switchNotifier;
  late bool insideCozy;

  setUp(() {
    insideCozy = false;
    PlatformInfo.isTestingForWeb = true;
    // onReady, queued by Get.replace, reads dotenv on the first frame.
    dotenv.testLoad(mergeWith: {'APP_GRID_AVAILABLE': 'unsupported'});
    when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
    when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
    when(labelController.isLabelSettingEnabled).thenReturn(RxBool(false));
    when(uuid.v1()).thenReturn('default-folder-id');
    when(createDefaultMailboxInteractor.execute(any, any, any))
        .thenAnswer((_) => Stream.value(Left(CreateDefaultMailboxFailure(null))));
    when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => _loadedFolders());
    clearInteractions(appToast);
    Get.replace(mailboxDashboardController);
    mailboxDashboardController.sessionCurrent = DelegationFixtures.session();
    source = ActiveAccountSourceFixtures.putShowing(DelegationFixtures.aliceAccountId);
    switchNotifier = _ScriptedSwitchNotifier(source)..shownOnSwitch = DelegationFixtures.bobAccountId;
  });

  tearDown(() => PlatformInfo.isTestingForWeb = false);

  /// Pumps a web app whose start URL holds [parameters], then loads the folders of the shown account.
  Future<void> startOn(WidgetTester tester, Map<String, dynamic> parameters) async {
    final container = ProviderContainer(overrides: [
      accountSwitchProvider.overrideWith(() => switchNotifier),
      accountSwitchViewFactoryProvider.overrideWithValue((_) => _FakeSwitchView()),
      appToastProvider.overrideWithValue(appToast),
      insideCozyProvider.overrideWith((ref) async => insideCozy),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: GetMaterialApp(
        locale: LocalizationService.defaultLocale,
        supportedLocales: LocalizationService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        getPages: [GetPage(name: AppRoutes.unknownRoutePage, page: () => const SizedBox())],
        home: const SizedBox(),
      ),
    ));
    addTearDown(() => Get.routing.current = '');
    // GetMaterialApp builds its navigator, the start's context, after the first frame.
    await tester.pumpAndSettle();
    mailboxController = newMailboxController(mailboxTreeBuilder: TreeBuilder())..onInit();
    // The router listener only sees values set after onInit, as the dashboard sets it in the app.
    mailboxDashboardController.routerParameters.value = parameters;
    await tester.pumpAndSettle();
  }

  Map<String, dynamic> emailUrlOf(AccountId? accountId) => {
        RouteUtils.paramID: urlEmailId.id.value,
        if (accountId != null) RouteUtils.paramAccount: accountId.id.value,
      };

  String? selectedMailboxId() => mailboxDashboardController.selectedMailbox.value?.id.id.value;

  group('a web start URL naming another account:', () {
    testWidgets('opens its email once the switch to that account shows it', (tester) async {
      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
      expect(mailboxDashboardController.dashBoardAction.value, OpenEmailWithoutMailboxFromLocationBar(urlEmailId));
      verifyNever(appToast.showToastWarningMessage(any, any));
    });

    testWidgets('inside Cozy opens its email once the switch to that account shows it', (tester) async {
      insideCozy = true;

      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
      expect(source.accountId, DelegationFixtures.bobAccountId);
      expect(mailboxDashboardController.dashBoardAction.value, OpenEmailWithoutMailboxFromLocationBar(urlEmailId));
      verifyNever(appToast.showToastWarningMessage(any, any));
    });

    testWidgets('opens my Inbox with the info toast, never its email, when the switch is refused', (tester) async {
      switchNotifier
        ..result = const AccountSwitchRefused(AccountSwitchRefusal.accountNotListed)
        ..shownOnSwitch = null;

      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
      expect(mailboxDashboardController.dashBoardAction.value, isNull);
      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
      verify(appToast.showToastWarningMessage(any, any)).called(1);
    });

    testWidgets('opens my Inbox, never its email, when a switch reports success for another account',
        (tester) async {
      switchNotifier.shownOnSwitch = null;

      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      expect(source.accountId, DelegationFixtures.aliceAccountId);
      expect(mailboxDashboardController.dashBoardAction.value, isNull);
      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
    });

    testWidgets('selects no folder before the switch ends', (tester) async {
      switchNotifier.pending = Completer<void>();

      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
      expect(selectedMailboxId(), isNull);
      switchNotifier.pending!.complete();
      await tester.pumpAndSettle();
      expect(mailboxDashboardController.dashBoardAction.value, OpenEmailWithoutMailboxFromLocationBar(urlEmailId));
    });

    testWidgets('a MailboxController closed during the switch opens nothing', (tester) async {
      switchNotifier.pending = Completer<void>();
      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      // As Get.delete closes it when the dashboard page goes away.
      mailboxController.onDelete();
      switchNotifier.pending!.complete();
      await tester.pumpAndSettle();

      expect(mailboxDashboardController.dashBoardAction.value, isNull);
      expect(selectedMailboxId(), isNull);
    });
  });

  group('a web start URL without a switch:', () {
    for (final (name, accountId) in [
      ('naming the shown account', DelegationFixtures.aliceAccountId),
      ('naming no account', null),
    ]) {
      testWidgets('$name opens its email without a switch', (tester) async {
        await startOn(tester, emailUrlOf(accountId));

        expect(switchNotifier.switchToCalls, isEmpty);
        expect(mailboxDashboardController.dashBoardAction.value, OpenEmailWithoutMailboxFromLocationBar(urlEmailId));
      });
    }

    testWidgets('off web, a URL naming another account runs no switch and opens my Inbox', (tester) async {
      PlatformInfo.isTestingForWeb = false;

      await startOn(tester, emailUrlOf(DelegationFixtures.bobAccountId));

      expect(switchNotifier.switchToCalls, isEmpty);
      expect(mailboxDashboardController.dashBoardAction.value, isNull);
      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
    });
  });

  group('a web start URL whose folder is missing:', () {
    Map<String, dynamic> missingFolderUrlOf(AccountId? accountId) => {
          RouteUtils.paramContext: 'missing-folder',
          if (accountId != null) RouteUtils.paramAccount: accountId.id.value,
        };

    testWidgets('opens the Inbox of the delegated account it names', (tester) async {
      source.show(
        DelegationFixtures.bobAccountId,
        ActiveAccount.delegated(DelegationFixtures.session(), DelegationFixtures.bobAccountId),
      );

      await startOn(tester, missingFolderUrlOf(DelegationFixtures.bobAccountId));

      expect(switchNotifier.switchToCalls, isEmpty);
      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
      expect(Get.currentRoute, isNot(AppRoutes.unknownRoutePage));
    });

    testWidgets('opens the Inbox of the delegated account instead of the folder shown before', (tester) async {
      source.show(
        DelegationFixtures.bobAccountId,
        ActiveAccount.delegated(DelegationFixtures.session(), DelegationFixtures.bobAccountId),
      );
      mailboxDashboardController.setSelectedMailbox(MailboxFixtures.sentMailbox.toPresentationMailbox());

      await startOn(tester, missingFolderUrlOf(DelegationFixtures.bobAccountId));

      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
    });

    testWidgets('of my account still opens the unknown page', (tester) async {
      await startOn(tester, missingFolderUrlOf(null));

      expect(Get.currentRoute, AppRoutes.unknownRoutePage);
      expect(selectedMailboxId(), isNull);
    });

    testWidgets('naming my account still opens the unknown page', (tester) async {
      await startOn(tester, missingFolderUrlOf(DelegationFixtures.aliceAccountId));

      expect(switchNotifier.switchToCalls, isEmpty);
      expect(Get.currentRoute, AppRoutes.unknownRoutePage);
      expect(selectedMailboxId(), isNull);
    });
  });

  group('a web start URL whose label is missing:', () {
    Map<String, dynamic> missingLabelUrlOf(AccountId? accountId) => {
          RouteUtils.paramLabelId: 'missing-label',
          if (accountId != null) RouteUtils.paramAccount: accountId.id.value,
        };

    void showBob() => source.show(
          DelegationFixtures.bobAccountId,
          ActiveAccount.delegated(DelegationFixtures.session(), DelegationFixtures.bobAccountId),
        );

    void stubLabels({required bool supported}) {
      when(labelController.isLabelCapabilitySupported(any, any)).thenReturn(supported);
      when(labelController.isLabelsLoaded).thenReturn(RxBool(true));
      when(labelController.labels).thenReturn(<Label>[].obs);
    }

    testWidgets('opens the Inbox of the delegated account when labels are not supported', (tester) async {
      showBob();
      stubLabels(supported: false);

      await startOn(tester, missingLabelUrlOf(DelegationFixtures.bobAccountId));

      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
      expect(Get.currentRoute, isNot(AppRoutes.unknownRoutePage));
    });

    testWidgets('opens the Inbox of the delegated account when the label is unknown', (tester) async {
      showBob();
      stubLabels(supported: true);

      await startOn(tester, missingLabelUrlOf(DelegationFixtures.bobAccountId));

      expect(selectedMailboxId(), MailboxFixtures.inboxMailbox.id!.id.value);
      expect(Get.currentRoute, isNot(AppRoutes.unknownRoutePage));
    });

    testWidgets('of my account still opens the unknown page', (tester) async {
      stubLabels(supported: true);

      await startOn(tester, missingLabelUrlOf(null));

      expect(Get.currentRoute, AppRoutes.unknownRoutePage);
      expect(selectedMailboxId(), isNull);
    });
  });
}

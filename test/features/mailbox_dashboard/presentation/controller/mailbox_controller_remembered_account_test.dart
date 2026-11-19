import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide State;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/last_shown_account_store_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/last_shown_account_store.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/account_switch_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/account_switch_view_factory_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/last_shown_account_providers.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_default_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/download_ui_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/providers/app_toast_provider.dart' show appToastProvider;
import 'package:tmail_ui_user/main/providers/cozy/inside_cozy_provider.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';

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

/// Selects the target on success like the real switch, so the recorder sees it.
class _RecordingSwitchNotifier extends AccountSwitchNotifier {
  final List<AccountId> switchToCalls = [];

  @override
  AccountSwitchState build() => const AccountSwitchIdle();

  @override
  Future<AccountSwitchResult> switchTo(AccountId targetAccountId, AccountSwitchView view) async {
    switchToCalls.add(targetAccountId);
    ref.read(activeAccountProvider.notifier).select(targetAccountId);
    return const AccountSwitched();
  }
}

class _LaunchedByNotificationManager extends IOSNotificationManager {
  @override
  Future<bool> wasAppLaunchedByNotification() async => true;
}

Stream<Either<Failure, Success>> _loadedFolders() async* {
  await Future<void>(() {});
  yield Right(GetAllMailboxSuccess(
    mailboxList: [MailboxFixtures.inboxMailbox.toPresentationMailbox()],
    currentMailboxState: State('mailbox-state'),
  ));
}

Stream<Either<Failure, Success>> _failedFolders() async* {
  await Future<void>(() {});
  yield Left(GetAllMailboxFailure(Exception('offline')));
}

void main() {
  setUpMailboxDashboardControllerTest();

  final alice = UserName(DelegationFixtures.aliceAddress);
  late _RecordingSwitchNotifier switchNotifier;
  late LastShownAccountStore store;

  setUp(() async {
    // A normal Android launch, as the notification plugin reports it.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (call) async => call.method == 'getNotificationAppLaunchDetails' ? {'notificationLaunchedApp': false} : null,
    );
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('dexterous.com/flutter/local_notifications'), null));
    dotenv.testLoad(mergeWith: {'APP_GRID_AVAILABLE': 'unsupported'});
    when(emailReceiveManager.pendingSharedFileInfo).thenAnswer((_) => BehaviorSubject.seeded([]));
    when(downloadController.downloadUIAction).thenAnswer((_) => Rxn(DownloadUIAction.idle));
    when(labelController.isLabelSettingEnabled).thenReturn(RxBool(false));
    when(uuid.v1()).thenReturn('default-folder-id');
    when(createDefaultMailboxInteractor.execute(any, any, any))
        .thenAnswer((_) => Stream.value(Left(CreateDefaultMailboxFailure(null))));
    when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => _loadedFolders());
    Get.replace(mailboxDashboardController);
    mailboxDashboardController.sessionCurrent = DelegationFixtures.session();
    ActiveAccountSourceFixtures.putShowing(DelegationFixtures.aliceAccountId);
    switchNotifier = _RecordingSwitchNotifier();
    SharedPreferences.setMockInitialValues({});
    store = LastShownAccountStoreImpl(await SharedPreferences.getInstance());
    await store.save(alice, DelegationFixtures.bobAccountId);
  });

  /// Pumps the mobile app on mine, as after the session read of a start, then loads its folders.
  Future<ProviderContainer> start(WidgetTester tester) async {
    final container = ProviderContainer(overrides: [
      accountSwitchProvider.overrideWith(() => switchNotifier),
      accountSwitchViewFactoryProvider.overrideWithValue((_) => _FakeSwitchView()),
      appToastProvider.overrideWithValue(appToast),
      insideCozyProvider.overrideWith((ref) async => false),
      lastShownAccountStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    container.read(activeAccountProvider.notifier).applySession(DelegationFixtures.session());
    DelegationFixtures.turnDelegationOn(container);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const GetMaterialApp(
        locale: LocalizationService.defaultLocale,
        supportedLocales: LocalizationService.supportedLocales,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SizedBox(),
      ),
    ));
    addTearDown(() => Get.routing.current = '');
    await tester.pumpAndSettle();
    mailboxController = newMailboxController(mailboxTreeBuilder: TreeBuilder())..onInit();
    // The dashboard sets the router parameters of a start once its session is read.
    mailboxDashboardController.routerParameters.value = {};
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('the first folder load of a mobile start shows the remembered account', (tester) async {
    final container = await start(tester);

    expect(switchNotifier.switchToCalls, [DelegationFixtures.bobAccountId]);
    expect(container.read(activeAccountProvider)?.accountId, DelegationFixtures.bobAccountId);
    expect(store.read(alice), DelegationFixtures.bobAccountId);
  });

  testWidgets('should not switch when the first folder load failed and keeps the account', (tester) async {
    when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => _failedFolders());

    await start(tester);

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(store.read(alice), DelegationFixtures.bobAccountId);
  });

  testWidgets('should not start again on a later folder load', (tester) async {
    when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => _failedFolders());
    await start(tester);
    when(getAllMailboxInteractor.execute(any, any)).thenAnswer((_) => _loadedFolders());

    mailboxController.getAllMailbox(DelegationFixtures.session(), DelegationFixtures.aliceAccountId);
    await tester.pumpAndSettle();

    expect(switchNotifier.switchToCalls, isEmpty);
  });

  testWidgets('should not switch on an iOS start from a notification tap and forgets the account', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    Get.put<IOSNotificationManager>(_LaunchedByNotificationManager());
    addTearDown(() => Get.delete<IOSNotificationManager>(force: true));

    await start(tester);
    debugDefaultTargetPlatformOverride = null;

    expect(switchNotifier.switchToCalls, isEmpty);
    expect(store.read(alice), isNull);
  });
}

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:delegation/model/delegate.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegated_account_providers.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegated_to_me_section.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegation_settings_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/my_delegates_section.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';
import 'delegation_settings_view_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ManageAccountDashBoardController>()])
void main() {
  late MockManageAccountDashBoardController dashboardController;
  late FakeDelegateRepository delegateRepository;
  late FakeDelegatedAccountRepository delegatedAccountRepository;

  setUp(() {
    Get.testMode = true;
    dashboardController = MockManageAccountDashBoardController();
    delegateRepository = FakeDelegateRepository();
    delegatedAccountRepository = FakeDelegatedAccountRepository();
    // GetX runs the lifecycle hooks when a controller is registered.
    when(dashboardController.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboardController.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboardController.sessionCurrent).thenReturn(DelegationFixtures.session());
    when(dashboardController.isDelegationSettingDisplayed).thenReturn(true);
    Get.put<ManageAccountDashBoardController>(dashboardController);
    Get.put(ResponsiveUtils());
    Get.put(ImagePaths());
  });

  tearDown(Get.reset);

  Future<void> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          delegateRepositoryProvider.overrideWithValue(delegateRepository),
          delegatedAccountRepositoryProvider.overrideWithValue(delegatedAccountRepository),
        ],
        child: const GetMaterialApp(
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocalizationService.supportedLocales,
          locale: LocalizationService.defaultLocale,
          home: Scaffold(body: DelegationSettingsView()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> openTab(WidgetTester tester, DelegationTab tab) async {
    await tester.tap(find.byKey(LinagoraSegmentedTabs.segmentKey(tab)));
    await tester.pump();
  }

  testWidgets('should open on the By me tab', (tester) async {
    await pumpView(tester);

    expect(find.byType(MyDelegatesSection), findsOneWidget);
    expect(find.byType(DelegatedToMeSection), findsNothing);
  });

  testWidgets('should show the mailboxes delegated to me on the With me tab', (tester) async {
    await pumpView(tester);
    await openTab(tester, DelegationTab.withMe);

    expect(find.byType(MyDelegatesSection), findsNothing);
    final section = tester.widget<DelegatedToMeSection>(find.byType(DelegatedToMeSection));
    expect(section.onSessionReloaded, dashboardController.applyReloadedSession);
  });

  testWidgets('should show my delegates again when going back to the By me tab', (tester) async {
    await pumpView(tester);
    await openTab(tester, DelegationTab.withMe);
    await openTab(tester, DelegationTab.byMe);

    expect(find.byType(MyDelegatesSection), findsOneWidget);
    expect(find.byType(DelegatedToMeSection), findsNothing);
  });

  for (final (layout, width, expectCentered) in [('mobile', 400.0, true), ('desktop', 1440.0, false)]) {
    testWidgets('should ${expectCentered ? '' : 'not '}center the tabs on $layout', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpView(tester);

      final tabsCenter = tester.getCenter(find.byType(LinagoraSegmentedTabs<DelegationTab>)).dx;
      expect(tabsCenter == width / 2, expectCentered);
    });
  }

  testWidgets('should show one remove action for an address that is both my delegate and an owner delegating to me', (
    tester,
  ) async {
    final bobAction = find.byKey(LinagoraPersonTile.actionKeyFor(DelegationFixtures.bobAddress));
    await pumpView(tester);
    await tester.runAsync(untilRepositoryCalled);
    delegateRepository.pendingGets.last.complete([
      Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress),
    ]);
    await tester.pumpAndSettle();

    expect(bobAction, findsOneWidget);

    await openTab(tester, DelegationTab.withMe);
    await tester.runAsync(untilRepositoryCalled);
    delegatedAccountRepository.pendingLoads.last.complete([
      DelegatedAccount(id: Id('bob-delegation'), username: DelegationFixtures.bobAddress),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(MyDelegatesSection), findsNothing);
    expect(bobAction, findsOneWidget);
  });
}

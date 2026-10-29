import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/route/settings_route_guard.dart';
import 'package:tmail_ui_user/main/pages/app_pages.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';

/// GetX keeps the pages of the first test, so every test counts into these.
int _settingsBindingsRunCount = 0;
int _dashboardBuildCount = 0;

class _RecordingBindings extends Bindings {
  @override
  void dependencies() => _settingsBindingsRunCount++;
}

const _dashboardText = 'dashboard';
const _settingsText = 'settings';

void main() {
  setUp(() {
    _settingsBindingsRunCount = 0;
    _dashboardBuildCount = 0;
    Get.routing.current = '';
    addTearDown(() => Get.routing.current = '');
  });

  Future<void> pumpApp(WidgetTester tester, {String? initialRoute}) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initialRoute ?? AppRoutes.dashboard,
      getPages: [
        GetPage(
          name: AppRoutes.dashboard,
          page: () {
            _dashboardBuildCount++;
            return const Text(_dashboardText);
          },
        ),
        GetPage(
          name: AppRoutes.settings,
          page: () => const Text(_settingsText),
          binding: _RecordingBindings(),
          middlewares: [SettingsRouteGuard()],
        ),
      ],
    ));
    await tester.pumpAndSettle();
  }

  group('while a delegated account is shown', () {
    setUp(() => ActiveAccountSourceFixtures.put(
          DelegationFixtures.session(),
          shownAccountId: DelegationFixtures.bobAccountId,
        ));

    testWidgets('/settings builds no Settings and goes back to the dashboard below it', (tester) async {
      await pumpApp(tester);

      Get.toNamed(AppRoutes.settings);
      await tester.pumpAndSettle();

      expect(_settingsBindingsRunCount, 0);
      expect(_dashboardBuildCount, 1);
      expect(find.text(_settingsText), findsNothing);
      expect(find.text(_dashboardText), findsOneWidget);
      expect(Get.currentRoute, AppRoutes.dashboard);
    });

    testWidgets('/settings with no route below opens the dashboard', (tester) async {
      await pumpApp(tester, initialRoute: AppRoutes.settings);

      expect(_settingsBindingsRunCount, 0);
      expect(find.text(_settingsText), findsNothing);
      expect(find.text(_dashboardText), findsOneWidget);
      expect(Get.currentRoute, AppRoutes.dashboard);
    });
  });

  for (final (shown, putSource) in [
    ('my own account', () => ActiveAccountSourceFixtures.put(DelegationFixtures.session())),
    ('no account yet', ActiveAccountSourceFixtures.putEmpty),
  ]) {
    testWidgets('/settings opens Settings while $shown is shown', (tester) async {
      putSource();
      await pumpApp(tester);

      Get.toNamed(AppRoutes.settings);
      await tester.pumpAndSettle();

      expect(_settingsBindingsRunCount, 1);
      expect(find.text(_settingsText), findsOneWidget);
      expect(Get.currentRoute, AppRoutes.settings);
    });
  }

  test('the Settings page of the app runs the guard', () {
    final settingsPage = AppPages.pages.singleWhere((page) => page.name == AppRoutes.settings);

    expect(settingsPage.middlewares, [isA<SettingsRouteGuard>()]);
  });
}

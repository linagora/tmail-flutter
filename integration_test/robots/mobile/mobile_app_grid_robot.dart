import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid/app_shortcut.dart';

import '../abstract/abstract_app_grid_robot.dart';

class MobileAppGridRobot implements AbstractAppGridRobot {
  const MobileAppGridRobot(this.$);

  final PatrolIntegrationTester $;

  @override
  List<String> get appNames => [
        'Twake Drive',
        'Twake Chat',
        if (PlatformInfo.isAndroid) 'Twake Sync',
      ];

  @override
  Future<void> expectListViewVisible() async {
    await $(#list_view_app_grid).waitUntilVisible();
  }

  @override
  Future<void> expectAppCountAndLabelsMatch() async {
    await $(AppShortcut).waitUntilVisible();
    expect(find.byType(AppShortcut), findsNWidgets(appNames.length));

    final listAppItem =
        $.tester.widgetList<AppShortcut>(find.byType(AppShortcut));

    final listAppNames = listAppItem.map((item) => item.label).toList();

    expect(listAppNames, equals(appNames));
  }

  @override
  Future<void> openAppInAppGrid() async {
    for (var appName in appNames) {
      await _open(appName);
    }
  }

  Future<void> _open(String appName) async {
    await $(appName).tap();
    await Future.delayed(const Duration(seconds: 2));
    await $.platformAutomator.mobile.pressHome();
    await $.platformAutomator.mobile.openApp();
    await $.platformAutomator.mobile.waitUntilVisible(
      MobileSelector(
        android: AndroidSelector(
          applicationPackage: 'com.linagora.android.teammail',
        ),
        ios: IOSSelector(identifier: 'com.linagora.ios.teammail'),
      ),
    );
  }
}

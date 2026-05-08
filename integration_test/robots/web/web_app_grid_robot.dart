import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_grid_dashboard_item.dart';

import '../mobile/mobile_app_grid_robot.dart';

class WebAppGridRobot extends MobileAppGridRobot {
  const WebAppGridRobot(super.$);

  @override
  List<String> get appNames => [
        'Twake',
        'Contacts',
        'Calendar',
        'TMail',
        'TDrive',
        'Teleskop',
      ];

  @override
  Future<void> expectListViewAppGridVisible() async {
    int totalApp = 6;
    await $(AppGridDashboardItem).waitUntilVisible();
    expect(find.byType(AppGridDashboardItem), findsNWidgets(totalApp));

    final listAppItem = $.tester
        .widgetList<AppGridDashboardItem>(find.byType(AppGridDashboardItem));

    final listAppNames = listAppItem.map((item) => item.app.appName).toList();

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
    // close tab
    await $.platformAutomator.web.pressKeyCombo(keys: ['Control', 'w']);
  }
}

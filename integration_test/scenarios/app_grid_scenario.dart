
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/app_grid_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_list_dashboard_item.dart';

import '../base/base_scenario.dart';
import '../robots/app_grid_robot.dart';
import '../robots/mailbox_menu_robot.dart';
import '../robots/thread_robot.dart';
import 'login_with_basic_auth_scenario.dart';

class AppGridScenario extends BaseScenario {

  final LoginWithBasicAuthScenario loginWithBasicAuthScenario;

  AppGridScenario(
    super.$,
    {
      required this.loginWithBasicAuthScenario
    }
  );

  @override
  Future<void> execute() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appGridRobot = AppGridRobot($);

    await loginWithBasicAuthScenario.execute();

    await threadRobot.openMailbox();
    await _expectMailboxViewVisible();
    await _expectAppGridViewVisible();

    await Future.delayed(const Duration(seconds: 2));

    await mailboxMenuRobot.openAppGrid();
    await _expectListViewAppGridVisible();
    await _expectAllAppInAppGridDisplayedIsFull();

    await appGridRobot.openAppInAppGridByAppName('Twake Drive');
    await Future.delayed(const Duration(seconds: 2));

    if (PlatformInfo.isAndroid) {
      await $.native.pressBack();

      await appGridRobot.openAppInAppGridByAppName('Twake Sync');
      await Future.delayed(const Duration(seconds: 2));

      await $.native.pressBack();

      await appGridRobot.openAppInAppGridByAppName('Twake Chat');
      await Future.delayed(const Duration(seconds: 2));

      await $.native.pressBack();

      await _expectMailboxViewVisible();
    } else if (PlatformInfo.isIOS) {
      await _expectMailboxViewInVisible();
    }
  }

  Future<void> _expectMailboxViewVisible() => expectViewVisible($(MailboxView));

  Future<void> _expectAppGridViewVisible() => expectViewVisible($(AppGridView));

  Future<void> _expectListViewAppGridVisible() => expectViewVisible($(#list_view_app_grid));

  Future<void> _expectAllAppInAppGridDisplayedIsFull() async {
    int totalApp = PlatformInfo.isIOS ? 2 : 3;
    expect(find.byType(AppListDashboardItem), findsNWidgets(totalApp));

    final listAppItem = $.tester
        .widgetList<AppListDashboardItem>(find.byType(AppListDashboardItem));

    final listAppNames = listAppItem.map((item) => item.app.appName).toList();

    if (PlatformInfo.isIOS) {
      expect(listAppNames, equals(['Twake Drive', 'Twake Chat']));
    } else {
      expect(listAppNames, equals(['Twake Drive', 'Twake Chat', 'Twake Sync']));
    }
  }

  Future<void> _expectMailboxViewInVisible() => expectViewInvisible($(MailboxView));
}
import 'package:core/data/constants/constant.dart';
import 'package:cozy/cozy_config_manager/cozy_config_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:universal_html/html.dart';

extension RegisterBrowserBackListener on MailboxDashBoardController {
  Future<void> registerBrowserBackListener() async {
    final isInsideCozy = await CozyConfigManager().isInsideCozy;
    if (!isInsideCozy) return;

    browserBackStreamSubscription = window.onPopState.listen((event) {
      var parameters = Map<String, String>.from(
        Uri.parse(window.location.href).queryParameters,
      );
      parameters[Constant.browserBackTriggerKeyword] = 'true';
      routerParameters.value = parameters;
    });
  }
}
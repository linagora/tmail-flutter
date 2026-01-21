import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;

extension CloseThreadDetailAction on ThreadDetailController {
  void closeThreadDetailAction() {
    if (PlatformInfo.isWeb && mailboxDashBoardController.isPopupMode.value) {
      html.window.close();
      return;
    }

    if (isSearchRunning) {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
    } else {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
    mailboxDashBoardController
      .dispatchEmailUIAction(CloseEmailInThreadDetailAction());
    Future.delayed(Duration.zero, () {
      mailboxDashBoardController.dispatchEmailUIAction(EmailUIAction());
    });

    onKeyboardShortcutDispose();

    reset();
  }
}
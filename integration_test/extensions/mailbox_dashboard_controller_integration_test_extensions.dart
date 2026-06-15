import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension MailboxDashboardControllerIntegrationTestExtensions on MailboxDashBoardController? {
  bool get isReady {
    return this != null &&
        this!.sessionCurrent != null &&
        this!.accountId.value != null &&
        this!.selectedMailbox.value != null &&
        this!.mapDefaultMailboxIdByRole.isNotEmpty;
  }
}
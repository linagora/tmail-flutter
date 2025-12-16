import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

extension HandleAiActionExtension on MailboxDashBoardController {
  bool get isAiCapabilitySupported {
    final currentAccountId = accountId.value;
    final currentSession = sessionCurrent;

    if (currentAccountId == null || currentSession == null) {
      return false;
    }

    return SessionExtensions.linagoraAICapability.isSupported(
      currentSession,
      currentAccountId,
    );
  }

  void autoRefreshCountEmailsInActionRequiredFolder() {
    if (isAiCapabilitySupported) {
      actionRequiredFolderController.getCountEmails(
        session: sessionCurrent,
        accountId: accountId.value,
      );
    }
  }
}

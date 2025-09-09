import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension ValidateSaasPremiumAvailableExtension on MailboxDashBoardController {
  bool get isPremiumAvailable {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }

    final saasAccount = sessionCurrent?.getSaaSAccountCapability(
      accountId.value!,
    );

    return saasAccount?.isPremiumAvailable ?? false;
  }
}

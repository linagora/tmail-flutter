import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension ValidatePremiumStorageExtension on MailboxDashBoardController {
  bool validatePremiumIsAvailable() {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }
    return isPremiumAvailable(
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }

  bool validateUserHasIsAlreadyHighestSubscription() {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }
    return isAlreadyHighestSubscription(
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }
}

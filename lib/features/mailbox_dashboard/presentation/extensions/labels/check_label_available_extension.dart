import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension CheckLabelAvailableExtension on MailboxDashBoardController {
  bool get isLabelAvailable {
    return labelController.isLabelSettingEnabled.isTrue &&
        isLabelCapabilitySupported;
  }
}

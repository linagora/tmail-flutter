
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleDrawerChangedExtension on MailboxDashBoardController {
  void handleDrawerChanged(bool isOpen) {
    log('HandleDrawerChangedExtension::handleDrawerChanged: isOpen = $isOpen');
    isDrawerOpened.value = isOpen;
  }
}
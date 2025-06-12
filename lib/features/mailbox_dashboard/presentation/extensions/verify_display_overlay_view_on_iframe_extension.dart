import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension VerifyDisplayOverlayViewOnIframeExtension
    on MailboxDashBoardController {
  bool get isDisplayedOverlayViewOnIFrame {
    return isAttachmentDraggableAppActive ||
        isLocalFileDraggableAppActive ||
        isAppGridDialogDisplayed.isTrue ||
        isDrawerOpened.isTrue ||
        isContextMenuOpened.isTrue;
  }
}

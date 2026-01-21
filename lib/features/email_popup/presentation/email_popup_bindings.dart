import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/email_popup/presentation/email_popup_controller.dart';
import 'package:tmail_ui_user/features/email_popup/presentation/popup_email_context_bindings.dart';

/// Bindings for the email popup route.
/// Uses lightweight PopupEmailContextBindings instead of full MailboxDashBoardBindings
/// to enable fast popup loading.
class EmailPopupBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize lightweight popup context bindings
    // (session, mailboxes, identities, download controller)
    PopupEmailContextBindings().dependencies();

    // Initialize popup controller
    Get.put(EmailPopupController());
  }

  /// Initialize email bindings after session is ready.
  /// Called from EmailPopupController when PopupEmailContextProvider reports ready.
  static void initializeEmailBindings({required dynamic emailId}) {
    EmailBindings(currentEmailId: emailId).dependencies();
  }
}


import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/contact_support_capability_extension.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnTapContactSupportAction = Function(ContactSupportCapability contactSupport);

mixin ContactSupportMixin {

  void onGetHelpOrReportBug(
      ContactSupportCapability contactSupport,
      MailboxDashBoardController mailboxDashBoardController,
  ) {
    log('ContactSupportMixin::onGetHelpOrReportBug:contactSupport = $contactSupport');
    if (contactSupport.isMailAddressSupported) {
      _handleMailAddress(contactSupport.supportMailAddress!, mailboxDashBoardController);
    } else if (contactSupport.isHttpLinkSupported) {
      _handleHttpLink(contactSupport.httpLink!);
    }
  }

  void _handleMailAddress(
    String mailAddress,
    MailboxDashBoardController mailboxDashBoardController,
  ) {
    mailboxDashBoardController.goToComposer(
      ComposerArguments.fromEmailAddress(EmailAddress(null, mailAddress)),
    );
  }

  void _handleHttpLink(String httpLink) {
    AppUtils.launchLink(httpLink);
  }
}
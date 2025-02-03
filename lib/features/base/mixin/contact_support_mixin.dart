
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/contact_support_capability_extension.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnTapContactSupportAction = Function(ContactSupportCapability contactSupport);

mixin ContactSupportMixin {

  void onGetHelpOrReportBug(ContactSupportCapability contactSupport) {
    if (contactSupport.isMailAddressSupported) {
      _handleMailAddress(contactSupport.supportMailAddress!);
    } else if (contactSupport.isHttpLinkSupported) {
      _handleHttpLink(contactSupport.httpLink!);
    }
  }

  void _handleMailAddress(String mailAddress) {
    final mailboxDashBoardController = getBinding<MailboxDashBoardController>();
    if (mailboxDashBoardController != null) {
      mailboxDashBoardController.goToComposer(
        ComposerArguments.fromEmailAddress(EmailAddress(null, mailAddress)),
      );
    } else {
      AppUtils.launchLink('${RouteUtils.mailtoPrefix}:$mailAddress');
    }
  }

  void _handleHttpLink(String httpLink) {
    AppUtils.launchLink(httpLink);
  }
}
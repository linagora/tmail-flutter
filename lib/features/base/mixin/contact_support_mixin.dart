
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/contact_support_capability_extension.dart';
import 'package:model/support/contact_support_capability.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OnTapContactSupportAction = Function(ContactSupportCapability contactSupport);

mixin ContactSupportMixin {

  void onGetHelpOrReportBug(
    ContactSupportCapability contactSupport,
    {String route = AppRoutes.dashboard}
  ) {
    if (contactSupport.isMailAddressSupported) {
      _handleMailAddress(contactSupport.supportMailAddress!, route: route);
    } else if (contactSupport.isHttpLinkSupported) {
      _handleHttpLink(contactSupport.httpLink!);
    }
  }

  void _handleMailAddress(String mailAddress, {String route = AppRoutes.dashboard}) {
    if (route == AppRoutes.settings && PlatformInfo.isWeb) {
      final mailtoLink = RouteUtils.generateMailtoLink(mailAddress);
      AppUtils.launchLink(mailtoLink);
    } else {
      final mailboxDashBoardController = getBinding<MailboxDashBoardController>();
      mailboxDashBoardController?.openComposer(
        ComposerArguments.fromEmailAddress(EmailAddress(null, mailAddress)),
      );
    }
  }

  void _handleHttpLink(String httpLink) {
    AppUtils.launchLink(httpLink);
  }
}
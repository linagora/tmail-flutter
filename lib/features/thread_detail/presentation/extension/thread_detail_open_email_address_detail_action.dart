import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ThreadDetailOpenEmailAddressDetailAction on ThreadDetailController {
  void openEmailAddressDetailAction(EmailAddress emailAddress) {
    if (session == null || accountId == null) return;

    emailActionReactor.openEmailAddressDialog(
      session!,
      accountId!,
      emailAddress: emailAddress,
      responsiveUtils: responsiveUtils,
      imagePaths: imagePaths,
      onComposeEmailFromEmailAddressRequest: (emailAddress) {
        popBack();
        mailboxDashBoardController.openComposer(
          ComposerArguments.fromEmailAddress(emailAddress),
        );
      },
      onQuickCreateRuleRequest: (quickCreateRuleStream) {
        consumeState(quickCreateRuleStream);
      },
    );
  }
}
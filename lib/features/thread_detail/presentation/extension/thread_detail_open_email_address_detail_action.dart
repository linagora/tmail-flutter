import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ThreadDetailOpenEmailAddressDetailAction on ThreadDetailController {
  void openEmailAddressDetailAction(EmailAddress emailAddress) {
    // The quick rule of this dialog is an email rule filter of my own account.
    final personalAccountId = mailboxDashBoardController.accountId.value;
    if (session == null || personalAccountId == null) return;

    emailActionReactor.openEmailAddressDialog(
      session!,
      personalAccountId,
      emailAddress: emailAddress,
      responsiveUtils: responsiveUtils,
      imagePaths: imagePaths,
      appToast: appToast,
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
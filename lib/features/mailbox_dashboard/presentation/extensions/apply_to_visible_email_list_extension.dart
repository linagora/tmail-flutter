import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/search_email_presentation_owner_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

typedef VisibleEmailListTransformer = List<PresentationEmail> Function(
  List<PresentationEmail> emails,
);

extension ApplyToVisibleEmailListExtension on MailboxDashBoardController {
  void applyToVisibleEmailList(
    VisibleEmailListTransformer transform, {
    bool Function()? shouldApplyToMailboxList,
  }) {
    final isSearchOwner = isSearchEmailPresentationOwner;
    if (!isSearchOwner && shouldApplyToMailboxList?.call() == false) {
      return;
    }

    final visibleEmails = isSearchOwner
        ? List<PresentationEmail>.from(
            appProviderContainer
                .read(searchEmailPresentationProvider)
                .listResultSearch,
          )
        : List<PresentationEmail>.from(emailsInCurrentMailbox);
    final updatedEmails = transform(visibleEmails);

    if (isSearchOwner) {
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .setResultSearches(updatedEmails);
    } else {
      updateEmailList(updatedEmails);
    }
  }
}

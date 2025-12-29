import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/presentation/filters/mailbox_filter_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension HandleEmailFilterExtension on ThreadController {
  MailboxFilterBuilder get _mailboxFilterBuilder => MailboxFilterBuilder(
        selectedMailbox: selectedMailbox,
        filterMessageOption:
            mailboxDashBoardController.filterMessageOption.value,
      );

  EmailFilter getEmailFilterForLoadMailbox() {
    return _mailboxFilterBuilder.buildEmailFilterForLoadMailbox();
  }

  Filter getFilterConditionForLoadMailbox({PresentationEmail? oldestEmail}) {
    return _mailboxFilterBuilder.buildFilterCondition(oldestEmail: oldestEmail);
  }

  EmailFilterCondition getFilterCondition() {
    return _mailboxFilterBuilder.buildDefaultMailboxFilter();
  }
}

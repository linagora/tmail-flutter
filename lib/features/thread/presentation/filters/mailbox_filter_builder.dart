import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class MailboxFilterBuilder {
  const MailboxFilterBuilder({
    required this.mailbox,
    required this.filterOption,
  });

  final PresentationMailbox? mailbox;
  final FilterMessageOption filterOption;

  EmailFilter build({PresentationEmail? oldestEmail}) {
    final baseFilter = EmailFilter(
      filter: buildFilterCondition(oldestEmail: oldestEmail),
    );

    if (mailbox == null || mailbox!.isFavorite) {
      return baseFilter;
    }

    if (mailbox!.isLabelMailbox) {
      return baseFilter.copyWith(mailboxId: mailbox!.id);
    }

    return baseFilter.copyWith(
      filterOption: filterOption,
      mailboxId: mailbox!.id,
    );
  }

  Filter buildFilterCondition({PresentationEmail? oldestEmail}) {
    final keyword = mailbox?.filterKeyword;

    if (keyword != null) {
      return _buildKeywordBasedFilter(
        keyword: keyword,
        oldestEmail: oldestEmail,
      );
    }

    return buildMailboxBasedFilter(
      mailboxId: mailbox?.id,
      oldestEmail: oldestEmail,
    );
  }

  Filter _buildKeywordBasedFilter({
    required String keyword,
    PresentationEmail? oldestEmail,
  }) {
    switch (filterOption) {
      case FilterMessageOption.unread:
        return EmailFilterCondition(
          notKeyword: KeyWordIdentifier.emailSeen.value,
          hasKeyword: keyword,
          before: oldestEmail?.receivedAt,
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          hasAttachment: true,
          hasKeyword: keyword,
          before: oldestEmail?.receivedAt,
        );

      case FilterMessageOption.starred:
        return LogicFilterOperator(
          Operator.AND,
          {
            EmailFilterCondition(
              hasKeyword: KeyWordIdentifier.emailFlagged.value,
            ),
            EmailFilterCondition(
              hasKeyword: keyword,
              before: oldestEmail?.receivedAt,
            ),
          },
        );

      default:
        return EmailFilterCondition(
          hasKeyword: keyword,
          before: oldestEmail?.receivedAt,
        );
    }
  }

  EmailFilterCondition buildMailboxBasedFilter({
    MailboxId? mailboxId,
    PresentationEmail? oldestEmail,
  }) {
    switch (filterOption) {
      case FilterMessageOption.all:
        return EmailFilterCondition(
          inMailbox: mailboxId,
          before: oldestEmail?.receivedAt,
        );

      case FilterMessageOption.unread:
        return EmailFilterCondition(
          inMailbox: mailboxId,
          notKeyword: KeyWordIdentifier.emailSeen.value,
          before: oldestEmail?.receivedAt,
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          inMailbox: mailboxId,
          hasAttachment: true,
          before: oldestEmail?.receivedAt,
        );

      case FilterMessageOption.starred:
        return EmailFilterCondition(
          inMailbox: mailboxId,
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: oldestEmail?.receivedAt,
        );
    }
  }
}

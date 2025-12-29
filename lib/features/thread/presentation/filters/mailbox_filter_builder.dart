import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class MailboxFilterBuilder {
  final PresentationMailbox? selectedMailbox;
  final FilterMessageOption filterMessageOption;

  const MailboxFilterBuilder({
    required this.selectedMailbox,
    required this.filterMessageOption,
  });

  MailboxId? get _mailboxId => selectedMailbox?.id;

  EmailFilter buildEmailFilterForLoadMailbox() {
    final filterCondition = buildFilterCondition();

    if (selectedMailbox?.isVirtualFolder == true) {
      return EmailFilter(filter: filterCondition);
    }

    return EmailFilter(
      filter: filterCondition,
      filterOption: filterMessageOption,
      mailboxId: _mailboxId,
    );
  }

  Filter buildFilterCondition({PresentationEmail? oldestEmail}) {
    final before = oldestEmail?.receivedAt;

    if (selectedMailbox?.isFavorite == true) {
      return _buildFavoriteMailboxFilter(before: before);
    }

    if (selectedMailbox?.isActionRequired == true) {
      return _buildActionRequiredMailboxFilter(before: before);
    }

    return buildDefaultMailboxFilter(before: before);
  }

  Filter _buildFavoriteMailboxFilter({UTCDate? before}) {
    switch (filterMessageOption) {
      case FilterMessageOption.unread:
        return EmailFilterCondition(
          notKeyword: KeyWordIdentifier.emailSeen.value,
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: before,
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          hasAttachment: true,
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: before,
        );

      default:
        return EmailFilterCondition(
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: before,
        );
    }
  }

  Filter _buildActionRequiredMailboxFilter({UTCDate? before}) {
    switch (filterMessageOption) {
      case FilterMessageOption.starred:
        return LogicFilterOperator(
          Operator.AND,
          {
            EmailFilterCondition(
              hasKeyword: KeyWordIdentifier.emailFlagged.value,
              before: before,
            ),
            EmailFilterCondition(
              notKeyword: KeyWordIdentifier.emailSeen.value,
              hasKeyword: KeyWordIdentifierExtension.needsActionMail.value,
              before: before,
            ),
          },
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          hasAttachment: true,
          notKeyword: KeyWordIdentifier.emailSeen.value,
          hasKeyword: KeyWordIdentifierExtension.needsActionMail.value,
          before: before,
        );

      default:
        return EmailFilterCondition(
          notKeyword: KeyWordIdentifier.emailSeen.value,
          hasKeyword: KeyWordIdentifierExtension.needsActionMail.value,
          before: before,
        );
    }
  }

  EmailFilterCondition buildDefaultMailboxFilter({UTCDate? before}) {
    switch (filterMessageOption) {
      case FilterMessageOption.all:
        return EmailFilterCondition(before: before);

      case FilterMessageOption.unread:
        return EmailFilterCondition(
          notKeyword: KeyWordIdentifier.emailSeen.value,
          before: before,
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(hasAttachment: true, before: before);

      case FilterMessageOption.starred:
        return EmailFilterCondition(
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: before,
        );
    }
  }
}

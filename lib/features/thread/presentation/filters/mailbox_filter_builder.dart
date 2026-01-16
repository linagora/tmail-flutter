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
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
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

  bool get _isVirtualFolder => selectedMailbox?.isVirtualFolder == true;

  bool get _isActionRequired => selectedMailbox?.isActionRequired == true;

  bool get _isFavorite => selectedMailbox?.isFavorite == true;

  bool get _isLabelMailbox => selectedMailbox?.isLabelMailbox == true;

  String? get _filterKeyword => selectedMailbox?.filterKeyword;

  EmailFilter buildEmailFilterForLoadMailbox() {
    final filterCondition = buildFilterCondition();

    if (_isVirtualFolder) {
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

    if (_isActionRequired) {
      return _buildActionRequiredMailboxFilter(before: before);
    }

    if (_isFavorite || _isLabelMailbox) {
      return _buildKeywordBasedFilter(keyword: _filterKeyword, before: before);
    }

    return buildDefaultMailboxFilter(before: before);
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

  Filter _buildKeywordBasedFilter({
    required String? keyword,
    UTCDate? before,
  }) {
    switch (filterMessageOption) {
      case FilterMessageOption.unread:
        return EmailFilterCondition(
          notKeyword: KeyWordIdentifier.emailSeen.value,
          hasKeyword: keyword,
          before: before,
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          hasAttachment: true,
          hasKeyword: keyword,
          before: before,
        );

      case FilterMessageOption.starred:
        return LogicFilterOperator(
          Operator.AND,
          {
            EmailFilterCondition(
              hasKeyword: KeyWordIdentifier.emailFlagged.value,
            ),
            EmailFilterCondition(hasKeyword: keyword, before: before),
          },
        );

      default:
        return EmailFilterCondition(hasKeyword: keyword, before: before);
    }
  }

  EmailFilterCondition buildDefaultMailboxFilter({UTCDate? before}) {
    switch (filterMessageOption) {
      case FilterMessageOption.all:
        return EmailFilterCondition(before: before, inMailbox: _mailboxId);

      case FilterMessageOption.unread:
        return EmailFilterCondition(
          notKeyword: KeyWordIdentifier.emailSeen.value,
          before: before,
          inMailbox: _mailboxId,
        );

      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          hasAttachment: true,
          before: before,
          inMailbox: _mailboxId,
        );

      case FilterMessageOption.starred:
        return EmailFilterCondition(
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: before,
          inMailbox: _mailboxId,
        );
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';

extension UpdateSearchFilterExtension on SearchEmailController {
  void deleteQuickSearchFilter({required QuickSearchFilter filter}) {
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        updateSimpleSearchFilter(hasAttachmentOption: const None());
        break;
      case QuickSearchFilter.starred:
        final keywords = Set<String>.from(listHasKeywordFiltered)
          ..remove(KeyWordIdentifier.emailFlagged.value);
        updateSimpleSearchFilter(
          hasKeywordOption: keywords.isEmpty ? const None() : Some(keywords),
        );
        break;
      case QuickSearchFilter.events:
        final keywords = Set<String>.from(listHasKeywordFiltered)
          ..remove(KeyWordIdentifierExtension.eventsMail.value);
        updateSimpleSearchFilter(
          hasKeywordOption: keywords.isEmpty ? const None() : Some(keywords),
        );
        break;
      case QuickSearchFilter.unread:
        updateSimpleSearchFilter(unreadOption: const None());
        break;
      case QuickSearchFilter.sortBy:
        updateSimpleSearchFilter(
          sortOrderTypeOption: const Some(SearchEmailFilter.defaultSortOrder),
        );
        break;
      case QuickSearchFilter.dateTime:
        updateSimpleSearchFilter(
          emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.allTime),
          startDateOption: const None(),
          endDateOption: const None(),
        );
        break;
      case QuickSearchFilter.from:
        updateSimpleSearchFilter(fromOption: const None());
        break;
      case QuickSearchFilter.to:
        updateSimpleSearchFilter(toOption: const None());
        break;
      case QuickSearchFilter.folder:
        updateSimpleSearchFilter(mailboxOption: const None());
        break;
      case QuickSearchFilter.labels:
        updateSimpleSearchFilter(labelOption: const None());
        break;
      default:
        break;
    }
    searchEmailAction();
  }

  void onSelectLabelFilter(Label? newLabel) {
    updateSimpleSearchFilter(labelOption: optionOf(newLabel));
    searchEmailAction();
  }
}

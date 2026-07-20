import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';

typedef _SearchFilterAction = void Function(SearchFilterNotifier notifier);

final _selectQuickSearchFilterActions = <QuickSearchFilter, _SearchFilterAction>{
  QuickSearchFilter.hasAttachment: (notifier) =>
      notifier.setHasAttachment(true.asSearchFilterToggle()),
  QuickSearchFilter.starred: (notifier) =>
      notifier.addHasKeyword(KeyWordIdentifier.emailFlagged.value),
  QuickSearchFilter.unread: (notifier) =>
      notifier.setUnread(true.asSearchFilterToggle()),
  QuickSearchFilter.events: (notifier) =>
      notifier.setNotIncludeEvents(true.asSearchFilterToggle()),
};

final _deleteQuickSearchFilterActions = <QuickSearchFilter, _SearchFilterAction>{
  QuickSearchFilter.dateTime: (notifier) =>
      notifier.setReceiveTime(EmailReceiveTimeType.allTime),
  QuickSearchFilter.sortBy: (notifier) =>
      notifier.setSortOrder(SearchEmailFilter.defaultSortOrder),
  QuickSearchFilter.from: (notifier) => notifier.clearSenders(),
  QuickSearchFilter.hasAttachment: (notifier) =>
      notifier.setHasAttachment(false.asSearchFilterToggle()),
  QuickSearchFilter.to: (notifier) => notifier.clearRecipients(),
  QuickSearchFilter.folder: (notifier) => notifier.clearMailbox(),
  QuickSearchFilter.labels: (notifier) => notifier.setLabel(null),
  QuickSearchFilter.starred: (notifier) =>
      notifier.removeHasKeyword(KeyWordIdentifier.emailFlagged.value),
  QuickSearchFilter.unread: (notifier) =>
      notifier.setUnread(false.asSearchFilterToggle()),
  QuickSearchFilter.events: (notifier) =>
      notifier.setNotIncludeEvents(false.asSearchFilterToggle()),
};

extension QuickFilterMutationExtension on SearchFilterNotifier {
  bool selectQuickSearchFilter(QuickSearchFilter filter) {
    final action = _selectQuickSearchFilterActions[filter];
    if (action == null) return false;
    action(this);
    return true;
  }

  bool deleteQuickSearchFilter(QuickSearchFilter filter) {
    final action = _deleteQuickSearchFilterActions[filter];
    if (action == null) return false;
    action(this);
    return true;
  }
}

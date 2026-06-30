import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

/// Shared `update`/`set`/`clear` for the committed and draft notifiers, so the two
/// can't diverge. The API takes **user intent only** — no `position`/`before`/`after`;
/// cursors live on the transient `SearchRequestSpec`, and `set` strips any that ride
/// in. On `$Notifier<SearchEmailFilter>` (the generated base) for `state` access.
/// See ADR-0093.
mixin SearchFilterMutation on $Notifier<SearchEmailFilter> {
  /// Partial update — only the given options change. `startDate`/`endDate` are
  /// user bounds (kept); cursors aren't settable here.
  void update({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<String>? subjectOption,
    Option<Set<String>>? notKeywordOption,
    Option<Set<String>>? hasKeywordOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<bool>? unreadOption,
    Option<bool>? notIncludeEventsOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
    Option<Label>? labelOption,
  }) {
    state = state.copyWith(
      fromOption: fromOption,
      toOption: toOption,
      textOption: textOption,
      subjectOption: subjectOption,
      notKeywordOption: notKeywordOption,
      hasKeywordOption: hasKeywordOption,
      mailboxOption: mailboxOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      unreadOption: unreadOption,
      notIncludeEventsOption: notIncludeEventsOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      sortOrderTypeOption: sortOrderTypeOption,
      labelOption: labelOption,
    );
  }

  /// Full replacement (commit a draft / apply a form); strips cursors so none can
  /// seed the SSOT.
  void set(SearchEmailFilter filter) => state = filter.clearPaginationCursors();

  /// Reset to `initial()`, keeping the current sort order.
  void clear() => state = SearchEmailFilter.withSortOrder(state.sortOrderType);
}

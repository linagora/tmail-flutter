import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_filter_input.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

/// Mutation API for the committed [SearchFilterNotifier]: `update`, `set`, and the
/// field helpers, so no call site owns the copyWith/set-rebuild plumbing. Takes
/// **user intent only** — no `position`/`before`/`after`; cursors live on the
/// transient `SearchRequestSpec`, and `set` strips any that ride in. On
/// `$Notifier<SearchEmailFilter>` (the generated base) for `state` access.
/// See ADR-0093.
mixin SearchFilterMutation on $Notifier<SearchEmailFilter> {
  /// Partial update — only the given options change. `startDate`/`endDate` are
  /// user bounds (kept); cursors aren't settable here.
  void update(SearchFilterPatch patch) {
    state = state.copyWith(
      fromOption: patch.fromOption,
      toOption: patch.toOption,
      textOption: patch.textOption,
      subjectOption: patch.subjectOption,
      notKeywordOption: patch.notKeywordOption,
      hasKeywordOption: patch.hasKeywordOption,
      mailboxOption: patch.mailboxOption,
      emailReceiveTimeTypeOption: patch.emailReceiveTimeTypeOption,
      hasAttachmentOption: patch.hasAttachmentOption,
      unreadOption: patch.unreadOption,
      notIncludeEventsOption: patch.notIncludeEventsOption,
      startDateOption: patch.startDateOption,
      endDateOption: patch.endDateOption,
      sortOrderTypeOption: patch.sortOrderTypeOption,
      labelOption: patch.labelOption,
    );
  }

  void setSenders(SearchFilterEmailSet senders) =>
      update(SearchFilterPatch()..fromOption = Some(senders.snapshot()));

  void clearSenders() =>
      setSenders(const <String>{}.asSearchFilterEmailSet());

  void setRecipients(SearchFilterEmailSet recipients) =>
      update(SearchFilterPatch()..toOption = Some(recipients.snapshot()));

  void clearRecipients() =>
      setRecipients(const <String>{}.asSearchFilterEmailSet());

  void setText(SearchFilterTextInput input) =>
      update(SearchFilterPatch()..textOption = input.searchQueryOption);

  void setSubject(SearchFilterTextInput input) =>
      update(SearchFilterPatch()..subjectOption = input.stringOption);

  void setNotKeywords(SearchFilterTextInput input) =>
      update(SearchFilterPatch()
        ..notKeywordOption = input.commaSeparatedSetOption);

  void setHasKeywords(SearchFilterKeywordSet hasKeywords) =>
      update(SearchFilterPatch()
        ..hasKeywordOption = Some(hasKeywords.snapshot()));

  void addHasKeyword(String keyword) =>
      setHasKeywords(({...state.hasKeyword}..add(keyword)).asSearchFilterKeywordSet());

  void removeHasKeyword(String keyword) =>
      setHasKeywords(({...state.hasKeyword}..remove(keyword)).asSearchFilterKeywordSet());

  void setMailbox(PresentationMailbox? mailbox) =>
      update(SearchFilterPatch()..mailboxOption = optionOf(mailbox));

  void clearMailbox() => setMailbox(null);

  void setHasAttachment(SearchFilterToggle hasAttachment) =>
      update(SearchFilterPatch()
        ..hasAttachmentOption = hasAttachment.exactOption);

  void toggleHasAttachment() =>
      setHasAttachment((!state.hasAttachment).asSearchFilterToggle());

  void setUnread(SearchFilterToggle unread) =>
      update(SearchFilterPatch()
        ..unreadOption = unread.enabledOnlyOption);

  void setNotIncludeEvents(SearchFilterToggle notIncludeEvents) =>
      update(SearchFilterPatch()
        ..notIncludeEventsOption = notIncludeEvents.enabledOnlyOption);

  void setSortOrder(EmailSortOrderType sortOrder) =>
      update(SearchFilterPatch()..sortOrderTypeOption = Some(sortOrder));

  void resetReceiveTime() =>
      update(SearchFilterPatch()
        ..emailReceiveTimeTypeOption = const Some(EmailReceiveTimeType.allTime)
        ..startDateOption = const None()
        ..endDateOption = const None());

  void setReceiveTime(
    EmailReceiveTimeType receiveTime, {
    UTCDate? startDate,
    UTCDate? endDate,
  }) => update(SearchFilterPatch()
        ..emailReceiveTimeTypeOption = Some(receiveTime)
        ..startDateOption = optionOf(startDate)
        ..endDateOption = optionOf(endDate));

  void toggleLast7Days() {
    if (state.emailReceiveTimeType == EmailReceiveTimeType.last7Days) {
      setReceiveTime(EmailReceiveTimeType.allTime);
    } else {
      final range = EmailReceiveTimeType.last7Days.toDateRange();
      setReceiveTime(
        EmailReceiveTimeType.last7Days,
        startDate: range.start,
        endDate: range.end,
      );
    }
  }

  void setLabel(Label? label) =>
      update(SearchFilterPatch()..labelOption = optionOf(label));

  void toggleLabel(Label? label) =>
      update(SearchFilterPatch()
        ..labelOption = optionOf(state.label?.id == label?.id ? null : label));

  void clearLabel() =>
      update(SearchFilterPatch()..labelOption = const None());
  /// 'starred' is the flagged keyword inside `hasKeyword`, not a bool field. Sets or
  /// clears it here so no call site rebuilds the keyword set.
  void setStarred(SearchFilterToggle starred) {
    final keyword = KeyWordIdentifier.emailFlagged.value;
    final hasKeyword = {...state.hasKeyword}..remove(keyword);
    if (starred.isSelected) hasKeyword.add(keyword);
    setHasKeywords(SearchFilterKeywordSet(hasKeyword));
  }

  /// Flips 'starred' from the current state — mirrors [toggleHasAttachment] so a
  /// suggestion chip never has to compute the new value itself.
  void toggleStarred() =>
      setStarred((!state.isContainFlagged).asSearchFilterToggle());

  void applyFilterMessageOption(FilterMessageOption option) {
    _setFilterMessageToggle(option, SearchFilterToggle.selected);
  }

  void syncFilterMessageOptionChange({
    required FilterMessageOption previous,
    required FilterMessageOption next,
  }) {
    if (previous == next) return;
    _setFilterMessageToggle(previous, SearchFilterToggle.unselected);
    _setFilterMessageToggle(next, SearchFilterToggle.selected);
  }

  void _setFilterMessageToggle(
    FilterMessageOption option,
    SearchFilterToggle toggle,
  ) {
    switch (option) {
      case FilterMessageOption.unread:
        setUnread(toggle);
      case FilterMessageOption.attachments:
        setHasAttachment(toggle);
      case FilterMessageOption.starred:
        setStarred(toggle);
      case FilterMessageOption.all:
        break;
    }
  }

  /// Adds/removes one address in `from`/`to` — encapsulates the read-set →
  /// mutate → pass-whole-set-back dance so no call site owns it.
  void addSender(SearchFilterEmailAddress address) =>
      setSenders(SearchFilterEmailSet({...state.from, address.value}));

  void removeSender(SearchFilterEmailAddress address) =>
      setSenders(SearchFilterEmailSet({...state.from}..remove(address.value)));

  void addRecipient(SearchFilterEmailAddress address) =>
      setRecipients(SearchFilterEmailSet({...state.to, address.value}));

  void removeRecipient(SearchFilterEmailAddress address) =>
      setRecipients(SearchFilterEmailSet({...state.to}..remove(address.value)));

  void toggleOnlySender(String address) {
    if (address.isEmpty) return;
    setSenders(
      (state.isOnlySender(address) ? <String>{} : {address})
          .asSearchFilterEmailSet(),
    );
  }

  /// Full replacement (apply a form); strips cursors so none can seed the SSOT.
  void set(SearchEmailFilter filter) => state = filter.clearPaginationCursors();
}

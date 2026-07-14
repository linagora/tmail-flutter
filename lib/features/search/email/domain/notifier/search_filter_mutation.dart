import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_filter_input.dart';

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

  void setRecipients(SearchFilterEmailSet recipients) =>
      update(SearchFilterPatch()..toOption = Some(recipients.snapshot()));

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

  void setMailbox(PresentationMailbox? mailbox) =>
      update(SearchFilterPatch()..mailboxOption = optionOf(mailbox));

  void setHasAttachment(SearchFilterToggle hasAttachment) =>
      update(SearchFilterPatch()
        ..hasAttachmentOption = hasAttachment.exactOption);

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

  void toggleLabel(Label? label) =>
      update(SearchFilterPatch()
        ..labelOption = optionOf(state.label?.id == label?.id ? null : label));

  void clearLabel() =>
      update(SearchFilterPatch()..labelOption = const None());
  /// 'starred' is the flagged keyword inside `hasKeyword`, not a bool field. Sets or
  /// clears it here so no call site rebuilds the keyword set.
  void toggleStarred(SearchFilterToggle starred) {
    final keyword = KeyWordIdentifier.emailFlagged.value;
    final hasKeyword = {...state.hasKeyword}..remove(keyword);
    if (starred.isSelected) hasKeyword.add(keyword);
    setHasKeywords(SearchFilterKeywordSet(hasKeyword));
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

  /// Full replacement (apply a form); strips cursors so none can seed the SSOT.
  void set(SearchEmailFilter filter) => state = filter.clearPaginationCursors();
}

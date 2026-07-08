import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SearchFilterPatch {
  Option<Set<String>>? fromOption;
  Option<Set<String>>? toOption;
  Option<SearchQuery>? textOption;
  Option<String>? subjectOption;
  Option<Set<String>>? notKeywordOption;
  Option<Set<String>>? hasKeywordOption;
  Option<PresentationMailbox>? mailboxOption;
  Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption;
  Option<bool>? hasAttachmentOption;
  Option<bool>? unreadOption;
  Option<bool>? notIncludeEventsOption;
  Option<UTCDate>? startDateOption;
  Option<UTCDate>? endDateOption;
  Option<EmailSortOrderType>? sortOrderTypeOption;
  Option<Label>? labelOption;
}

class SearchFilterTextInput {
  final String value;

  const SearchFilterTextInput(this.value);

  String get trimmedValue => value.trim();

  Option<SearchQuery> get searchQueryOption =>
      option(trimmedValue.isNotEmpty, SearchQuery(trimmedValue));

  Option<String> get stringOption =>
      option(trimmedValue.isNotEmpty, trimmedValue);

  Option<Set<String>> get commaSeparatedSetOption =>
      option(
        trimmedValue.isNotEmpty,
        trimmedValue.split(',').map((value) => value.trim()).toSet(),
      );
}

class SearchFilterEmailAddress {
  final String value;

  const SearchFilterEmailAddress(this.value);
}

class SearchFilterEmailSet {
  final Set<String> value;

  const SearchFilterEmailSet(this.value);

  Set<String> snapshot() => Set<String>.of(value);
}

class SearchFilterKeywordSet {
  final Set<String> value;

  const SearchFilterKeywordSet(this.value);

  Set<String> snapshot() => Set<String>.of(value);
}

enum SearchFilterToggle {
  selected,
  unselected;

  bool get isSelected => this == SearchFilterToggle.selected;

  Option<bool> get exactOption => Some(isSelected);

  Option<bool> get enabledOnlyOption =>
      isSelected ? const Some(true) : const None();
}

extension SearchFilterTextInputExtension on String {
  SearchFilterTextInput asSearchFilterTextInput() =>
      SearchFilterTextInput(this);

  SearchFilterEmailAddress asSearchFilterEmailAddress() =>
      SearchFilterEmailAddress(this);
}

extension SearchFilterStringSetExtension on Set<String> {
  SearchFilterEmailSet asSearchFilterEmailSet() =>
      SearchFilterEmailSet(this);

  SearchFilterKeywordSet asSearchFilterKeywordSet() =>
      SearchFilterKeywordSet(this);
}

extension SearchFilterToggleExtension on bool {
  SearchFilterToggle asSearchFilterToggle() =>
      this ? SearchFilterToggle.selected : SearchFilterToggle.unselected;
}

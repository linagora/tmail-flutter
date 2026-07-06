import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

/// Pure assertions on filter state and search results.
abstract class AbstractSearchResultAssertionRobot {
  /// Asserts the suggestion-overlay chip reads as selected.
  Future<void> expectQuickSearchFilterSelected(QuickSearchFilter filter);

  /// Asserts no result email carries [subject].
  Future<void> expectEmailSubjectNotPresent(String subject);

  /// Asserts the advanced-search attachment checkbox is checked.
  Future<void> expectAdvancedSearchHasAttachmentChecked();
}

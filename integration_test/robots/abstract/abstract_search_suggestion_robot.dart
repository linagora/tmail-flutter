import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

/// Quick-search filter chips in the suggestion overlay. Web-only.
abstract class AbstractSearchSuggestionRobot {
  Future<void> tapQuickSearchFilter(QuickSearchFilter filter);
}

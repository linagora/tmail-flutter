import 'abstract_search_assertion_robot.dart';
import 'abstract_search_filter_robot.dart';
import 'abstract_search_input_robot.dart';

import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

abstract class AbstractSearchRobot
    implements
        AbstractSearchInputRobot,
        AbstractSearchFilterRobot,
        AbstractSearchAssertionRobot {
  Future<void> openSearch();
  Future<void> searchByLabel(String labelName);
  Future<void> expectEmailWithSubjectVisible(String subject);
  Future<void> expectEmptyResults();
  Future<void> expectSuggestionFilterSelected(QuickSearchFilter filter, bool selected);
  Future<void> tapSuggestionFilter(QuickSearchFilter filter);
  Future<void> deleteSuggestionFilter(QuickSearchFilter filter);
  Future<void> expectQuickFilterDateTimeSelected(bool selected);
  Future<void> tapQuickFilterDateTimeChip();
  Future<void> selectQuickFilterDateTimeOption(String dateTimeName);
}

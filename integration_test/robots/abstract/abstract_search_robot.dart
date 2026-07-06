import 'abstract_search_assertion_robot.dart';
import 'abstract_search_filter_robot.dart';
import 'abstract_search_input_robot.dart';
import 'abstract_search_result_assertion_robot.dart';
import 'abstract_search_suggestion_robot.dart';

abstract class AbstractSearchRobot
    implements
        AbstractSearchInputRobot,
        AbstractSearchFilterRobot,
        AbstractSearchAssertionRobot {
  AbstractSearchSuggestionRobot get suggestion;
  AbstractSearchResultAssertionRobot get assertion;

  Future<void> openSearch();
  Future<void> searchByLabel(String labelName);
  Future<void> expectEmailWithSubjectVisible(String subject);
  Future<void> expectEmptyResults();
}

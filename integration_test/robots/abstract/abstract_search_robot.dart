import 'abstract_search_assertion_robot.dart';
import 'abstract_search_email_action_robot.dart';
import 'abstract_search_filter_robot.dart';
import 'abstract_search_input_robot.dart';
import 'abstract_search_result_assertion_robot.dart';
import 'abstract_search_suggestion_robot.dart';
import 'abstract_search_viewport_robot.dart';

abstract class AbstractSearchRobot
    implements
        AbstractSearchInputRobot,
        AbstractSearchFilterRobot,
        AbstractSearchAssertionRobot {
  AbstractSearchSuggestionRobot get suggestion;
  AbstractSearchResultAssertionRobot get assertion;
  AbstractSearchEmailActionRobot get action;
  AbstractSearchViewportRobot get viewport;

  Future<void> openSearch();
  Future<void> searchByLabel(String labelName);
  Future<void> expectEmailWithSubjectVisible(String subject);
  Future<void> expectEmptyResults();
}

import 'abstract_search_input_robot.dart';
import 'abstract_search_result_robot.dart';
import 'abstract_search_sort_robot.dart';

// Composite interface — keeps the factory signature stable (robots.searchRobot()
// returns AbstractSearchRobot) while the real contracts live in focused interfaces.
//
// Adding methods to any sub-interface keeps each contract small and leaves
// unrelated robots unaffected.
abstract class AbstractSearchRobot
    implements
        AbstractSearchInputRobot,
        AbstractSearchSortRobot,
        AbstractSearchResultRobot {}

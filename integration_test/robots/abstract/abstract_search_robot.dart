import 'abstract_search_assertion_robot.dart';
import 'abstract_search_filter_robot.dart';
import 'abstract_search_input_robot.dart';

abstract class AbstractSearchRobot
    implements
        AbstractSearchInputRobot,
        AbstractSearchFilterRobot,
        AbstractSearchAssertionRobot {}

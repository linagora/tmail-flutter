import 'package:patrol/patrol.dart';

abstract class AbstractMailboxNavigationRobot {
  Future<void> openFolder(PatrolFinder finder);
  Future<void> longPressMailbox(PatrolFinder finder);
  Future<void> expandMailbox(PatrolFinder finder);
  Future<void> tapMailbox(PatrolFinder finder);
}

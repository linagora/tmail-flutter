import 'package:patrol/patrol.dart';

abstract class AbstractMailboxAssertionRobot {
  Future<void> expectMailboxVisible(PatrolFinder finder);
  Future<void> expectSubfolderNotExist(PatrolFinder finder);
  Future<void> expectMailboxSelected(PatrolFinder mailbox);
  Future<void> expectLabelSelected(PatrolFinder label);
}

import 'abstract_thread_assertion_robot.dart';
import 'abstract_thread_empty_trash_robot.dart';

abstract class AbstractThreadRobot {
  AbstractThreadAssertionRobot get assertion;
  AbstractThreadEmptyTrashRobot get emptyTrash;

  Future<void> openComposer();
  Future<void> openAppGrid();
  Future<void> openMailbox();
  Future<void> openEmailWithSubject(String subject);
  Future<void> tapOnSearchField();
}

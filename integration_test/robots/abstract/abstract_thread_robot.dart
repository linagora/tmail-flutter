import 'abstract_thread_assertion_robot.dart';
import 'abstract_thread_empty_trash_robot.dart';
import 'abstract_thread_viewport_robot.dart';

abstract class AbstractThreadRobot {
  AbstractThreadAssertionRobot get assertion;
  AbstractThreadEmptyTrashRobot get emptyTrash;

  /// Window resizing, null where the platform keeps the device viewport.
  AbstractThreadViewportRobot? get viewport;

  Future<void> openComposer();
  Future<void> openAppGrid();
  Future<void> openMailbox();
  Future<void> openEmailWithSubject(String subject);
  Future<void> tapOnSearchField();
  Future<void> pullToRefreshByEmailSubject(String subject);
  Future<void> deepPullToRefreshByEmailSubject(String subject);
}

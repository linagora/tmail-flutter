import 'abstract_email_assertion_robot.dart';
import 'abstract_email_label_robot.dart';

abstract class AbstractEmailRobot {
  AbstractEmailAssertionRobot get assertion;
  AbstractEmailLabelRobot get label;

  Future<void> tapDownloadAllButton();
  Future<void> expectDownloadSaveDialogVisible();
}

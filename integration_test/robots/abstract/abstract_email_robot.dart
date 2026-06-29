import 'abstract_email_assertion_robot.dart';
import 'abstract_email_twp_warning_robot.dart';

abstract class AbstractEmailRobot {
  Future<void> tapDownloadAllButton();
  Future<void> expectDownloadSaveDialogVisible();

  /// Pure assertions for the email detail view.
  AbstractEmailAssertionRobot get assertion;

  /// Actions on the `X-TWP-Message` warning banner.
  AbstractEmailTwpWarningRobot get twpWarning;
}

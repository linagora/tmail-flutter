import 'abstract_email_assertion_robot.dart';
import 'abstract_email_label_robot.dart';
import 'abstract_email_pdf_preview_robot.dart';

abstract class AbstractEmailRobot {
  AbstractEmailPdfPreviewRobot get pdfPreview;
  AbstractEmailAssertionRobot get assertion;
  AbstractEmailLabelRobot get label;

  Future<void> tapDownloadAllButton();
  /// Opens the email more-actions menu and picks Edit as new.
  Future<void> editAsNewEmail();
  Future<void> expectDownloadSaveDialogVisible();
}

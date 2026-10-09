import 'abstract_email_pdf_preview_assertion_robot.dart';

abstract class AbstractEmailPdfPreviewRobot {
  AbstractEmailPdfPreviewAssertionRobot get assertion;

  Future<void> openAttachment();
  Future<void> submitPassword(String password);
  Future<void> cancelPasswordPrompt();
}

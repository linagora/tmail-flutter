import 'abstract_email_pdf_preview_robot.dart';

abstract class AbstractEmailRobot {
  AbstractEmailPdfPreviewRobot get pdfPreview;

  Future<void> tapDownloadAllButton();
  Future<void> expectDownloadSaveDialogVisible();
}

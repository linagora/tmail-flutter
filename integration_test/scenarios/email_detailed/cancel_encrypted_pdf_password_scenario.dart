import 'encrypted_pdf_attachment_scenario.dart';

class CancelEncryptedPdfPasswordScenario extends EncryptedPdfAttachmentScenario {
  const CancelEncryptedPdfPasswordScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final pdfPreviewRobot =
        await openEncryptedPdfAttachment('cancel encrypted pdf password');

    await pdfPreviewRobot.cancelPasswordPrompt();
    await pdfPreviewRobot.assertion.expectPasswordProtectedMessage();
  }
}

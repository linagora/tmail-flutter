import '../../resources/encrypted_pdf_resources.dart';
import 'encrypted_pdf_attachment_scenario.dart';

class OpenEncryptedPdfAttachmentScenario extends EncryptedPdfAttachmentScenario {
  const OpenEncryptedPdfAttachmentScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    final pdfPreviewRobot =
        await openEncryptedPdfAttachment('open encrypted pdf attachment');

    await pdfPreviewRobot.submitPassword('wrong-password');
    await pdfPreviewRobot.assertion.expectPasswordPrompt(
      showsIncorrectPassword: true,
    );

    await pdfPreviewRobot.submitPassword(EncryptedPdfResources.password);
    await pdfPreviewRobot.assertion.expectPdfOpened();
  }
}

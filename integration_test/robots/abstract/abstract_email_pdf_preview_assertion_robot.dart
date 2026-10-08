abstract class AbstractEmailPdfPreviewAssertionRobot {
  Future<void> expectPasswordPrompt({required bool showsIncorrectPassword});
  Future<void> expectPdfOpened();
  Future<void> expectPasswordProtectedMessage();
}

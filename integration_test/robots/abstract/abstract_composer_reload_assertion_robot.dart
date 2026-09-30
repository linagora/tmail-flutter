abstract class AbstractComposerReloadAssertionRobot {
  void expectSnapshotAbsent();
  void expectSnapshotPresent();
  Future<void> expectComposerAbsent();
  Future<void> expectRestoredComposerVisible();
  Future<void> expectRestoredContent(
    String subject,
    String recipient,
    String body,
  );
  bool isDiscardConfirmationVisible();
  Future<void> expectSnapshotRemoved();
}

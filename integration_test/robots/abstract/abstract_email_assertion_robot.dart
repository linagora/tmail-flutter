abstract class AbstractEmailAssertionRobot {
  Future<void> expectLabelPickerVisible();
  Future<void> expectLabelShownOnEmailSubject(String labelDisplayName);
}

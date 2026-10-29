import 'abstract_language_assertion_robot.dart';

abstract class AbstractLanguageRobot {
  AbstractLanguageAssertionRobot get assertion;

  Future<void> openLanguagePicker();
}

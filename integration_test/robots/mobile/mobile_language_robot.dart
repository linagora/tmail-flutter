import '../abstract/abstract_language_assertion_robot.dart';
import '../abstract/abstract_language_robot.dart';
import '../language_robot.dart';
import 'mobile_language_assertion_robot.dart';

class MobileLanguageRobot extends LanguageRobot
    implements AbstractLanguageRobot {
  MobileLanguageRobot(super.$);

  @override
  AbstractLanguageAssertionRobot get assertion =>
      MobileLanguageAssertionRobot($);

  @override
  Future<void> openLanguagePicker() async {
    await openLanguageContextMenu();
    await $.pumpAndSettle();
  }
}

import 'abstract_composer_reload_assertion_robot.dart';

abstract class AbstractComposerReloadRobot {
  AbstractComposerReloadAssertionRobot get assertion;

  void captureCurrentComposer();
  Future<void> waitForContentReady(
    String subject,
    String recipient,
    String body,
  );
  void dispatchBeforeUnload();
  void tearDownWithoutClose();
  Future<void> restoreFromCache();
}

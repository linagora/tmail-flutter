/// Web only: real key presses sent to whatever element holds page focus,
/// whether it is a Flutter widget or an element inside an editor iframe.
abstract class AbstractHardwareKeyboardRobot {
  Future<void> pressKey(String key);
}

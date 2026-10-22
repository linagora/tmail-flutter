abstract class AbstractComposerOsKeyboardRobot {
  Future<void> focusSubject();
  Future<void> focusBody();
  Future<void> typeText(String text);
  Future<void> pressKey(String key);
  Future<String> readSubject();
  Future<String> readBodyHtml();
  Future<void> waitForSubject(String expected);
  Future<void> waitForBodyContaining(String expected);
}

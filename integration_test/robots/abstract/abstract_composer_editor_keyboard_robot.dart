import 'abstract_composer_editor_assertion_robot.dart';

abstract class AbstractComposerEditorKeyboardRobot {
  AbstractComposerEditorAssertionRobot get assertion;

  // Cmd+Shift+7 on macOS, Ctrl+Shift+7 elsewhere — Summernote's bullet list shortcut.
  Future<void> startBulletListViaKeyboardShortcut();
  Future<void> pressEditorKey(String key);
  Future<void> enterTextWithKeyboard(String text);
}

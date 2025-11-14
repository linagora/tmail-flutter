import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension HandleInsertEmojiToEditorExtension on ComposerController {
  void insertEmojiToEditor(String emoji) {
    log('$runtimeType::insertEmojiToEditor: Emoji is $emoji');
    richTextWebController?.insertEmoji(emoji);
  }

  void handleOpenEmojiPicker() {
    log('$runtimeType::handleOpenEmojiPicker:');
    clearFocusRecipients();
    clearFocusSubject();
    richTextWebController?.editorController.setFocus();
  }
}

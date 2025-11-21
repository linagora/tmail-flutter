import 'package:tmail_ui_user/features/ai/presentation/model/ai_scribe_menu_action.dart';

// TODO: In the future, prompts will be loaded from a remote source
class AIPrompts {
  static String buildPrompt(AIScribeMenuAction action, String text) {
    switch (action) {
      case AIScribeMenuAction.translateFrench:
        return translateTo(text, 'French');
      case AIScribeMenuAction.translateEnglish:
        return translateTo(text, 'English');
      case AIScribeMenuAction.translateRussian:
        return translateTo(text, 'Russian');
      case AIScribeMenuAction.translateVietnamese:
        return translateTo(text, 'Vietnamese');
      case AIScribeMenuAction.summarize:
        return summarize(text);
    }
  }

  static String translateTo(String text, String language) {
    return 'Translate the following text to $language:\n\n$text';
  }

  static String summarize(String text) {
    return 'Summarize the following text in a concise manner preserving the meaning:\n\n$text';
  }
}

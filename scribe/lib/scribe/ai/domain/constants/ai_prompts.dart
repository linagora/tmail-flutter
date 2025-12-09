import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';

// TODO
// In a near future, prompts will be loaded from a remote source
class AIPrompts {
  static String buildPrompt(AIAction action, String? text) {
    return switch (action) {
      PredefinedAction(action: final menuAction) => buildPredefinedPrompt(menuAction, text ?? ''),
      CustomPromptAction(prompt: final customPrompt) => buildCustomPrompt(customPrompt, text),
    };
  }

  static String buildPredefinedPrompt(AIScribeMenuAction action, String text) {
    switch (action) {
      case AIScribeMenuAction.correctGrammar:
        return correctGrammar(text);
      case AIScribeMenuAction.improveMakeShorter:
        return improveMakeShorter(text);
      case AIScribeMenuAction.improveExpandContext:
        return improveExpandContext(text);
      case AIScribeMenuAction.improveEmojify:
        return improveEmojify(text);
      case AIScribeMenuAction.improveTransformToBullets:
        return improveTransformToBullets(text);
      case AIScribeMenuAction.changeToneProfessional:
        return changeToneTo(text, 'professional');
      case AIScribeMenuAction.changeToneCasual:
        return changeToneTo(text, 'casual');
      case AIScribeMenuAction.changeTonePolite:
        return changeToneTo(text, 'polite');
      case AIScribeMenuAction.translateFrench:
        return translateTo(text, 'French');
      case AIScribeMenuAction.translateEnglish:
        return translateTo(text, 'English');
      case AIScribeMenuAction.translateRussian:
        return translateTo(text, 'Russian');
      case AIScribeMenuAction.translateVietnamese:
        return translateTo(text, 'Vietnamese');
    }
  }

  static String improveMakeShorter(String text) {
    return 'Make the following text shorter and more concise. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String improveExpandContext(String text) {
    return 'Expand the context of the following text to make it more detailed and comprehensive. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String improveEmojify(String text) {
    return 'Add appropriate emojis to the following text to make it more expressive. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String improveTransformToBullets(String text) {
    return 'Transform the following text into a bulleted list format. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String correctGrammar(String text) {
    return 'Correct grammar of the following text. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String changeToneTo(String text, String tone) {
    return 'Change the tone of the following text to be more $tone. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String translateTo(String text, String language) {
    return 'Translate the following text to $language. Output only the result. Preserve input formatting. Text:\n\n$text';
  }

  static String buildCustomPrompt(String customPrompt, String? text) {
    if (text == null) {
      return customPrompt;
    }

    return '$customPrompt\n\nText:\n\n$text';
  }
}

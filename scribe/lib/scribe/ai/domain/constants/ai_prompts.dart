import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';

const PERFORM_TASK = "Perform only the following task:";
const PRESERVE_LANGUAGE_PROMPT = "Do not translate. Strictly keep the original language of the input text. For example, if it's French, keep French. If it's English, keep English.";
const DO_NOT_ADD_INFO_PROMPT = "Do not add any extra information or interpret anything beyond the explicit task.";

// TODO
// In a near future, prompts will be loaded from a remote source
class AIPrompts {
  static String buildPrompt(AIAction action, String? text) {
    return switch (action) {
      PredefinedAction(action: final menuAction) =>
        buildPredefinedPrompt(menuAction, text ?? ''),
      CustomPromptAction(prompt: final customPrompt) =>
        buildCustomPrompt(customPrompt, text),
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
    return '$PERFORM_TASK make the text shorter but preserve the meaning. $PRESERVE_LANGUAGE_PROMPT $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String improveExpandContext(String text) {
    return '$PERFORM_TASK expand the context of the text to make it more detailed and comprehensive. $PRESERVE_LANGUAGE_PROMPT $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String improveEmojify(String text) {
    return '$PERFORM_TASK add emojis to the important parts of the text. Do not try to rephrase or replace text. $PRESERVE_LANGUAGE_PROMPT $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String improveTransformToBullets(String text) {
    return '$PERFORM_TASK transform the text in a bullet list. $PRESERVE_LANGUAGE_PROMPT $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String correctGrammar(String text) {
    return '$PERFORM_TASK correct grammar and spelling. $PRESERVE_LANGUAGE_PROMPT $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String changeToneTo(String text, String tone) {
    return '$PERFORM_TASK change the tone to be $tone. $PRESERVE_LANGUAGE_PROMPT $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String translateTo(String text, String language) {
    return '$PERFORM_TASK translate. Translate the text to the specified language: $language. $DO_NOT_ADD_INFO_PROMPT Text:\n\n$text';
  }

  static String buildCustomPrompt(String customPrompt, String? text) {
    if (text == null) {
      return customPrompt;
    }

    return 'You help the user write an email following his instruction: $customPrompt\n\nDo not output a subject or a signature, only the content of the email. Text:\n\n$text';
  }
}

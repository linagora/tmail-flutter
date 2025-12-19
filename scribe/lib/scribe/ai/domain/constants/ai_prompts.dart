import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';

class AIPrompts {
  static const _performTask = "Perform only the following task:";
  static const _preserveLanguagePrompt =
      "Do not translate. Strictly keep the original language of the input text. For example, if it's French, keep French. If it's English, keep English.";
  static const _doNotAddInfoPrompt =
      "Do not add any extra information or interpret anything beyond the explicit task.";

  static String buildPrompt(AIAction action, String? text) {
    return switch (action) {
      PredefinedAction(action: final menuAction) =>
      text?.trim().isNotEmpty == true
          ? buildPredefinedPrompt(menuAction, text!)
          :  throw ArgumentError('Text cannot be empty for predefined actions'),
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
    return '$_performTask make the text shorter but preserve the meaning. $_preserveLanguagePrompt $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String improveExpandContext(String text) {
    return '$_performTask expand the context of the text to make it more detailed and comprehensive. $_preserveLanguagePrompt $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String improveEmojify(String text) {
    return '$_performTask add emojis to the important parts of the text. Do not try to rephrase or replace text. $_preserveLanguagePrompt $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String improveTransformToBullets(String text) {
    return '$_performTask transform the text into a bullet list. $_preserveLanguagePrompt $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String correctGrammar(String text) {
    return '$_performTask correct grammar and spelling. $_preserveLanguagePrompt $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String changeToneTo(String text, String tone) {
    return '$_performTask change the tone to be $tone. $_preserveLanguagePrompt $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String translateTo(String text, String language) {
    return '$_performTask translate. Translate the text to the specified language: $language. $_doNotAddInfoPrompt Text:\n\n$text';
  }

  static String buildCustomPrompt(String customPrompt, String? text) {
    if (text == null) {
      return customPrompt;
    }

    return 'You help the user write an email following his instruction: $customPrompt\n\nDo not output a subject or a signature, only the content of the email. Text:\n\n$text';
  }
}

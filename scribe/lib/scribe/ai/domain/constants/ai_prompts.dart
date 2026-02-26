import 'package:scribe/scribe/ai/data/model/ai_message.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_action.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';
import 'package:scribe/scribe/ai/data/service/prompt_service.dart';
import 'package:get/get.dart';

class AIPrompts {
  static final PromptService _promptService = Get.find<PromptService>();

  static Future<List<AIMessage>> buildPrompt(AIAction action, String? text) async {
    return switch (action) {
      PredefinedAction(action: final menuAction) =>
        buildActionPrompt(menuAction, text),
      CustomPromptAction(prompt: final customPrompt) =>
        buildCustomPrompt(customPrompt, text),
    };
  }

  static Future<List<AIMessage>> buildActionPrompt(AIScribeMenuAction menuAction, String? text) async {
    if (text == null || text.trim().isEmpty) {
      throw ArgumentError('Text cannot be empty for predefined actions');
    }
    return await _promptService.buildPromptByName(menuAction.promptId, text);
  }

  static Future<List<AIMessage>> buildCustomPrompt(String customPrompt, String? text) async {
    return await _promptService.buildPromptByName(CustomPromptAction.promptId, text ?? '', task: customPrompt);
  }
}

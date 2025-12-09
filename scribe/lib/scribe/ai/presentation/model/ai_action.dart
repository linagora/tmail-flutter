import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';

sealed class AIAction {
  const AIAction();

  String get label;
}

class PredefinedAction extends AIAction {
  final AIScribeMenuAction action;

  const PredefinedAction(this.action);

  @override
  String get label => action.fullLabel;
}

class CustomPromptAction extends AIAction {
  final String prompt;

  const CustomPromptAction(this.prompt);

  @override
  String get label => 'Help me write';
}

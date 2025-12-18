import 'package:scribe/scribe.dart';

sealed class AIAction {
  const AIAction();

  String getLabel(ScribeLocalizations localizations);
}

class PredefinedAction extends AIAction {
  final AIScribeMenuAction action;

  const PredefinedAction(this.action);

  @override
  String getLabel(ScribeLocalizations localizations) =>
      action.getFullLabel(localizations);
}

class CustomPromptAction extends AIAction {
  final String prompt;

  const CustomPromptAction(this.prompt);

  @override
  String getLabel(ScribeLocalizations localizations) {
    return localizations.customPromptAction;
  }
}

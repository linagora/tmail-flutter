import 'package:flutter/material.dart';
import 'package:scribe/scribe/ai/localizations/scribe_localizations.dart';
import 'package:scribe/scribe/ai/presentation/model/ai_scribe_menu_action.dart';

sealed class AIAction {
  const AIAction();

  String getLabel(BuildContext context);
}

class PredefinedAction extends AIAction {
  final AIScribeMenuAction action;

  const PredefinedAction(this.action);

  @override
  String getLabel(BuildContext context) => action.getFullLabel(context);
}

class CustomPromptAction extends AIAction {
  final String prompt;

  const CustomPromptAction(this.prompt);

  @override
  String getLabel(BuildContext context) {
    return ScribeLocalizations.of(context)!.customPromptAction;
  }
}

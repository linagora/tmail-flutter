
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension ListRuleFilterActionArgumentExtension on List<RuleFilterActionArguments> {

  bool isEmptySelectedRuleAction() => every((argument) => argument is EmptyRuleFilterActionArguments);

  String getPreviewWhenEditing(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return where((arguments) => arguments.action != null).map((arguments) {
      if (arguments is MoveMessageActionArguments) {
        return '${arguments.action!.getTitle(appLocalizations)} ${appLocalizations.toFolder.toLowerCase()} "${arguments.mailbox?.getDisplayName(context) ?? ''}"';
      } else {
        return arguments.action!.getTitle(appLocalizations);
      }
    }).join(', ');
  }
}
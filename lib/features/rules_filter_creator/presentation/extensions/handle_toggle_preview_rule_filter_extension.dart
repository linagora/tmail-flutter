import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:flutter/material.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/tmail_rule_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/list_rule_filter_action_argument_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/rules_filter_creator_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleTogglePreviewRuleFilterExtension
    on RulesFilterCreatorController {
  void handleTogglePreviewRuleFilter() {
    isPreviewEnabled.value = !isPreviewEnabled.value;
  }

  String getConditionPreview(AppLocalizations appLocalizations) {
    final conditionCombiner =
    (conditionCombinerType.value ?? ConditionCombiner.AND)
        .getTitle(appLocalizations)
        .toUpperCase();
    final conditionValue = listRuleCondition.getPreviewWhenEditing(
      appLocalizations,
    );

    return appLocalizations.ruleFilterConditionPreviewMessage(
      conditionCombiner,
      conditionValue,
    );
  }

  String getActionPreview(BuildContext context) {
    final actionValue = listEmailRuleFilterActionSelected.getPreviewWhenEditing(
      context,
    );

    return '${AppLocalizations.of(context).actions.inCaps}: $actionValue';
  }
}

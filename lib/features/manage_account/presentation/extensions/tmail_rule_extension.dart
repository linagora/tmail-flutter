import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/extensions/rule_condition_extensions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension TmailRuleExtension on TMailRule {
  String getPreview(AppLocalizations appLocalizations) {
    final firstCondition = conditionGroup?.conditions.firstOrNull ?? condition;
    if (firstCondition != null) {
      return firstCondition.getPreview(appLocalizations);
    }
    return '';
  }
}

extension RuleConditionExtension on RuleCondition {
  String getPreview(AppLocalizations appLocalizations) {
    return '${field.getTitle(appLocalizations)}, ${comparator.getTitle(appLocalizations).toLowerCase()}: $value';
  }

  String getPreviewWhenEditing(AppLocalizations appLocalizations) {
    return '${field.getTitle(appLocalizations)} ${comparator.getTitle(appLocalizations).toLowerCase()} "$value"';
  }
}

extension ListRuleConditionExtension on List<RuleCondition> {
  String getPreviewWhenEditing(AppLocalizations appLocalizations) {
    return map((e) => e.getPreviewWhenEditing(appLocalizations)).join(', ');
  }
}

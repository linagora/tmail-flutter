
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:rule_filter/rule_filter/rule_condition_group.dart' as rule_combiner;

extension RuleConditionFieldExtension on rule_condition.Field {

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case rule_condition.Field.from:
        return appLocalizations.ruleFilterAddressFromField;
      case rule_condition.Field.to:
        return appLocalizations.ruleFilterAddressToField;
      case rule_condition.Field.cc:
        return appLocalizations.ruleFilterAddressCcField;
      case rule_condition.Field.recipient:
        return appLocalizations.recipient;
      case rule_condition.Field.subject:
        return appLocalizations.subject;
    }
  }
}

extension RuleConditionComparatorExtension on rule_condition.Comparator {

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case rule_condition.Comparator.contains:
        return appLocalizations.contains;
      case rule_condition.Comparator.notContains:
        return appLocalizations.notContains;
      case rule_condition.Comparator.exactlyEquals:
        return appLocalizations.exactlyEquals;
      case rule_condition.Comparator.notExactlyEquals:
        return appLocalizations.notExactlyEquals;
    }
  }
}

extension RuleConditionCombinerExtension on rule_combiner.ConditionCombiner {

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case rule_combiner.ConditionCombiner.AND:
        return appLocalizations.all;
      case rule_combiner.ConditionCombiner.OR:
        return appLocalizations.any;
    }
  }
}
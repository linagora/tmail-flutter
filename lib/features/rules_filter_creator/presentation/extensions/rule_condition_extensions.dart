
import 'package:flutter/cupertino.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart' as rule_condition;
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension RuleConditionFieldExtension on rule_condition.Field {

  String getTitle(BuildContext context) {
    switch(this) {
      case rule_condition.Field.from:
        return AppLocalizations.of(context).ruleFilterAddressFromField;
      case rule_condition.Field.to:
        return AppLocalizations.of(context).ruleFilterAddressToField;
      case rule_condition.Field.cc:
        return AppLocalizations.of(context).ruleFilterAddressCcField;
      case rule_condition.Field.recipient:
        return AppLocalizations.of(context).recipient;
      case rule_condition.Field.subject:
        return AppLocalizations.of(context).subject;
    }
  }
}

extension RuleConditionComparatorExtension on rule_condition.Comparator {

  String getTitle(BuildContext context) {
    switch(this) {
      case rule_condition.Comparator.contains:
        return AppLocalizations.of(context).contains;
      case rule_condition.Comparator.notContains:
        return AppLocalizations.of(context).notContains;
      case rule_condition.Comparator.exactlyEquals:
        return AppLocalizations.of(context).exactlyEquals;
      case rule_condition.Comparator.notExactlyEquals:
        return AppLocalizations.of(context).notExactlyEquals;
    }
  }
}
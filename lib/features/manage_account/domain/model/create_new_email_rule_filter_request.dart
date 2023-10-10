
import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class CreateNewEmailRuleFilterRequest with EquatableMixin {

  final List<TMailRule> currentListTMailRules;
  final TMailRule newTMailRule;

  CreateNewEmailRuleFilterRequest(this.currentListTMailRules, this.newTMailRule);

  List<TMailRule> get newListTMailRules {
    final newListRules = <TMailRule>[];
    for (var rule in currentListTMailRules) {
      if (rule.conditionGroup != null) {
        final newRule = TMailRule(
          id: rule.id,
          name: rule.name,
          action: rule.action,
          conditionGroup: rule.conditionGroup,
        );
        newListRules.add(newRule);
      } else {
        newListRules.add(rule);
      }
    }
    newListRules.insert(0, newTMailRule);
    log('CreateNewEmailRuleFilterRequest::newListTMailRules(): $newListRules');
    return newListRules;
  }

  @override
  List<Object?> get props => [currentListTMailRules, newTMailRule];
}
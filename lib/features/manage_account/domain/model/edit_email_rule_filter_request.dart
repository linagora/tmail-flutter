
import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class EditEmailRuleFilterRequest with EquatableMixin {

  final List<TMailRule> currentListTMailRules;
  final TMailRule tMailRuleChanged;

  EditEmailRuleFilterRequest(this.currentListTMailRules, this.tMailRuleChanged);

  List<TMailRule> get listTMailRulesUpdated {
    final listRulesUpdated = currentListTMailRules
        .map((rule) {
            if (rule.id == tMailRuleChanged.id) {
              return tMailRuleChanged;
            } 
            if (rule.conditionGroup != null) {
              return TMailRule(
                id: rule.id,
                name: rule.name,
                action: rule.action,
                conditionGroup: rule.conditionGroup,
              );
            }
            return rule;
          })
        .toList();

    log('EditEmailRuleFilterRequest::listTMailRulesUpdated(): $listRulesUpdated');
    return listRulesUpdated;
  }

  @override
  List<Object?> get props => [currentListTMailRules, tMailRuleChanged];
}
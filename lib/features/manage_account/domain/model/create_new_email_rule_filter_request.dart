
import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class CreateNewEmailRuleFilterRequest with EquatableMixin {

  final List<TMailRule> currentListTMailRules;
  final TMailRule newTMailRule;

  CreateNewEmailRuleFilterRequest(this.currentListTMailRules, this.newTMailRule);

  List<TMailRule> get newListTMailRules {
    final newListRules = currentListTMailRules;
    newListRules.insert(0, newTMailRule);
    log('CreateNewEmailRuleFilterRequest::newListTMailRules(): $newListRules');
    return newListRules;
  }

  @override
  List<Object?> get props => [currentListTMailRules, newTMailRule];
}
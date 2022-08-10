import 'package:equatable/equatable.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

class DeleteEmailRuleRequest with EquatableMixin {
  final TMailRule emailRuleDelete;
  final List<TMailRule> currentEmailRules;

  DeleteEmailRuleRequest({
    required this.emailRuleDelete,
    required this.currentEmailRules,
  });

  @override
  List<Object?> get props => [emailRuleDelete, currentEmailRules];
}

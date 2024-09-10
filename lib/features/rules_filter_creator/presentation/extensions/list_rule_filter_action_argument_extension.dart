
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rule_filter_action_arguments.dart';

extension ListRuleFilterActionArgumentExtension on List<RuleFilterActionArguments> {

  bool isEmptySelectedRuleAction() => every((argument) => argument is EmptyRuleFilterActionArguments);
}
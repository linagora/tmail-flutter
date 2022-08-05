import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/converter/rule_id_converter.dart';
import 'package:rule_filter/rule.dart';
import 'package:rule_filter/rule_action.dart';
import 'package:rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_id.dart';

part 'tmail_rule.g.dart';

@JsonSerializable()
@RuleIdConverter()
class TMailRule extends Rule {

  final RuleId id;
  final String name;
  final RuleCondition condition;
  final RuleAction action;

  TMailRule(
      this.id,
      this.name,
      this.condition,
      this.action,
      );

  factory TMailRule.fromJson(Map<String, dynamic> json) =>
      _$TMailRuleFromJson(json);

  Map<String, dynamic> toJson() => _$TMailRuleToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    condition,
    action,
  ];
}
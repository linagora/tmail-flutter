import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/converter/rule_id_nullable_converter.dart';
import 'package:rule_filter/rule_filter/rule.dart';
import 'package:rule_filter/rule_filter/rule_action.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';
import 'package:rule_filter/rule_filter/rule_id.dart';

part 'tmail_rule.g.dart';

@RuleIdNullableConverter()
@IdConverter()
@JsonSerializable(explicitToJson: true)
class TMailRule extends Rule {
  final RuleId? id;
  final String name;
  final RuleCondition condition;
  final RuleAction action;

  TMailRule({
    this.id,
    required this.name,
    required this.condition,
    required this.action,
  });

  factory TMailRule.fromJson(Map<String, dynamic> json) =>
      _$TMailRuleFromJson(json);

  Map<String, dynamic> toJson() => _$TMailRuleToJson(this);

  @override
  List<Object?> get props => [
        name,
        condition,
        action,
      ];

  TMailRule copyWith({
    RuleId? id,
    String? name,
    RuleCondition? condition,
    RuleAction? action,
  }) {
    return TMailRule(
      id: id ?? this.id,
      name: name ?? this.name,
      condition: condition ?? this.condition,
      action: action ?? this.action,
    );
  }
}

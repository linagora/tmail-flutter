import 'package:jmap_dart_client/jmap/core/filter/filter_condition.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/rule_condition.dart';

part 'rule_condition_group.g.dart';

enum ConditionCombiner {
  @JsonValue('AND')
  AND,
  @JsonValue('OR')
  OR
}

@JsonSerializable()
class RuleConditionGroup extends FilterCondition {
  final ConditionCombiner conditionCombiner;
  
  final List<RuleCondition> conditions;
  
  RuleConditionGroup({
    required this.conditionCombiner,
    required this.conditions,
  });

  @override
  List<Object?> get props => [
        conditionCombiner,
        conditions,
      ];

  factory RuleConditionGroup.fromJson(Map<String, dynamic> json) =>
      _$RuleConditionGroupFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RuleConditionGroupToJson(this);

}

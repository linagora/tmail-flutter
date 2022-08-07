import 'package:jmap_dart_client/jmap/core/filter/filter_condition.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_condition.g.dart';

enum Field {
  @JsonValue('from')
  from,
  @JsonValue('to')
  to,
  @JsonValue('cc')
  cc,
  @JsonValue('recipient')
  recipient,
  @JsonValue('subject')
  subject,
}

enum Comparator {
  @JsonValue('contains')
  contains,
  @JsonValue('not-contains')
  notContains,
  @JsonValue('exactly-equals')
  exactlyEquals,
  @JsonValue('not-exactly-equals')
  notExactlyEquals,
}

@JsonSerializable()
class RuleCondition extends FilterCondition {
  final Field field;

  final Comparator comparator;

  final String value;

  RuleCondition({
    required this.field,
    required this.comparator,
    required this.value,
  });

  @override
  List<Object?> get props => [
        field,
        comparator,
        value,
      ];

  factory RuleCondition.fromJson(Map<String, dynamic> json) =>
      _$RuleConditionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RuleConditionToJson(this);
}

import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/converter/rule_filter_id_coverter.dart';
import 'package:rule_filter/rule_filter/rule_filter_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';

part 'rule_filter.g.dart';

@RuleFilterIdConverter()
@JsonSerializable()
class RuleFilter extends Filter {
  final RuleFilterId id;
  final List<TMailRule> rules;

  RuleFilter({
    required this.id,
    required this.rules,
  });

  factory RuleFilter.fromJson(Map<String, dynamic> json) =>
      _$RuleFilterFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RuleFilterToJson(this);

  @override
  List<Object?> get props => [
        id,
        rules,
      ];
}

import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/converter/rule_id_converter.dart';
import 'package:rule_filter/rule_id.dart';

part 'rule_filter.g.dart';

@RuleIdConverter()
@JsonSerializable()
class RuleFilter extends Filter {

  final RuleId id;

  RuleFilter(this.id);

  factory RuleFilter.fromJson(Map<String, dynamic> json) =>
      _$RuleFilterFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RuleFilterToJson(this);

  @override
  List<Object?> get props => [id];
}
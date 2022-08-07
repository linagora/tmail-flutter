import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter/converter/rule_filter_id_coverter.dart';

enum RuleFilterIdType {
  singleton('singleton');

  const RuleFilterIdType(this.value);

  final String value;
}

@RuleFilterIdConverter()
@IdConverter()
@JsonSerializable()
class RuleFilterId with EquatableMixin {
  final Id id;

  RuleFilterId({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}

extension RuleFilterIdSingleton on RuleFilterId {
  static RuleFilterId get ruleFilterIdSingleton => RuleFilterId(id: Id(RuleFilterIdType.singleton.value));
}

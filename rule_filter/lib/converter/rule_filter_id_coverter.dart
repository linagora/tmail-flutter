import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_filter_id.dart';

class RuleFilterIdConverter implements JsonConverter<RuleFilterId, String> {
  const RuleFilterIdConverter();

  @override
  RuleFilterId fromJson(String json) => RuleFilterId(id: Id(json));

  @override
  String toJson(RuleFilterId object) => object.id.value;
}

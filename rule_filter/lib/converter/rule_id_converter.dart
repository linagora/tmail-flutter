import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rule_filter/rule_id.dart';

class RuleIdConverter implements JsonConverter<RuleId, String> {
  const RuleIdConverter();

  @override
  RuleId fromJson(String json) => RuleId(id: Id(json));

  @override
  String toJson(RuleId object) => object.id.value;
}

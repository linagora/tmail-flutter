import 'package:forward/forward/forward_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

class ForwardIdConverter implements JsonConverter<ForwardId, String> {
  const ForwardIdConverter();

  @override
  ForwardId fromJson(String json) => ForwardId(id: Id(json));

  @override
  String toJson(ForwardId object) => object.id.value;
}

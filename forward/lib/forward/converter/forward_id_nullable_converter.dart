import 'package:forward/forward/forward_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

class ForwardIdNullableConverter implements JsonConverter<ForwardId?, String?> {
  const ForwardIdNullableConverter();

  @override
  ForwardId? fromJson(String? json) => json != null ? ForwardId(id: Id(json)) : null;

  @override
  String? toJson(ForwardId? object) => object?.id.value;
}

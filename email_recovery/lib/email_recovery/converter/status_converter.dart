import 'package:email_recovery/email_recovery/status.dart';
import 'package:json_annotation/json_annotation.dart';

class StatusConverter implements JsonConverter<Status, String> {
  const StatusConverter();

  @override
  Status fromJson(String json) => Status(json);

  @override
  String toJson(Status object) => object.value;
}
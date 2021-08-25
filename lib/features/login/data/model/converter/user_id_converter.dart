import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';

class UserIdConverter implements JsonConverter<UserId, String> {
  const UserIdConverter();

  @override
  UserId fromJson(String json) => UserId(json);

  @override
  String toJson(UserId object) => object.id;
}

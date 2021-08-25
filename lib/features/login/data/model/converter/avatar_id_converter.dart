import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';

class AvatarIdConverter implements JsonConverter<AvatarId, String> {
  const AvatarIdConverter();

  @override
  AvatarId fromJson(String json) => AvatarId(json);

  @override
  String toJson(AvatarId object) => object.id;
}

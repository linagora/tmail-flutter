import 'package:json_annotation/json_annotation.dart';
import 'package:model/model.dart';

class AvatarIdNullableConverter implements JsonConverter<AvatarId?, String?> {
  const AvatarIdNullableConverter();

  @override
  AvatarId? fromJson(String? json) => json != null ? AvatarId(json) : AvatarId.initial();

  @override
  String? toJson(AvatarId? object) => object?.id;
}

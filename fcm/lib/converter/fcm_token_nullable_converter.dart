import 'package:fcm/model/fcm_token.dart';
import 'package:json_annotation/json_annotation.dart';

class FcmTokenNullableConverter implements JsonConverter<FcmToken?, String?> {
  const FcmTokenNullableConverter();

  @override
  FcmToken? fromJson(String? json) => json != null ? FcmToken(json) : null;

  @override
  String? toJson(FcmToken? object) => object?.value;
}

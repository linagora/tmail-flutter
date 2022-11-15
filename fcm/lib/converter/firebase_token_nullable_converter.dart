import 'package:fcm/model/firebase_token.dart';
import 'package:json_annotation/json_annotation.dart';

class FirebaseTokenNullableConverter implements JsonConverter<FirebaseToken?, String?> {
  const FirebaseTokenNullableConverter();

  @override
  FirebaseToken? fromJson(String? json) => json != null ? FirebaseToken(json) : null;

  @override
  String? toJson(FirebaseToken? object) => object?.value;
}

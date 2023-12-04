import 'package:fcm/model/firebase_registration_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

class FirebaseRegistrationIdNullableConverter implements JsonConverter<FirebaseRegistrationId?, String?> {
  const FirebaseRegistrationIdNullableConverter();

  @override
  FirebaseRegistrationId? fromJson(String? json) => json != null ? FirebaseRegistrationId(Id(json)) : null;

  @override
  String? toJson(FirebaseRegistrationId? object) => object?.id.value;
}

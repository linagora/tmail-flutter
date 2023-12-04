import 'package:fcm/model/firebase_registration_expired_time.dart';
import 'package:jmap_dart_client/http/converter/utc_date_converter.dart';
import 'package:jmap_dart_client/http/converter/utc_date_nullable_converter.dart';
import 'package:json_annotation/json_annotation.dart';

class FirebaseRegistrationExpiredTimeNullableConverter implements JsonConverter<FirebaseRegistrationExpiredTime?, String?> {
  const FirebaseRegistrationExpiredTimeNullableConverter();

  @override
  FirebaseRegistrationExpiredTime? fromJson(String? json) {
    if (json != null) {
      return FirebaseRegistrationExpiredTime(const UTCDateConverter().fromJson(json));
    } else {
      return null;
    }
  }

  @override
  String? toJson(FirebaseRegistrationExpiredTime? object) => const UTCDateNullableConverter().toJson(object?.value);
}
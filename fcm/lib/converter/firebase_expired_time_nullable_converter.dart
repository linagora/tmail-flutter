import 'package:fcm/model/firebase_expired_time.dart';
import 'package:jmap_dart_client/http/converter/utc_date_converter.dart';
import 'package:jmap_dart_client/http/converter/utc_date_nullable_converter.dart';
import 'package:json_annotation/json_annotation.dart';

class FirebaseExpiredTimeNullableConverter implements JsonConverter<FirebaseExpiredTime?, String?> {
  const FirebaseExpiredTimeNullableConverter();

  @override
  FirebaseExpiredTime? fromJson(String? json) {
    if (json != null) {
      return FirebaseExpiredTime(const UTCDateConverter().fromJson(json));
    } else {
      return null;
    }
  }

  @override
  String? toJson(FirebaseExpiredTime? object) => const UTCDateNullableConverter().toJson(object?.value);
}
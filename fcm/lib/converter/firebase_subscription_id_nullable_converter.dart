import 'package:fcm/model/firebase_subscription_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

class FirebaseSubscriptionIdNullableConverter implements JsonConverter<FirebaseSubscriptionId?, String?> {
  const FirebaseSubscriptionIdNullableConverter();

  @override
  FirebaseSubscriptionId? fromJson(String? json) => json != null ? FirebaseSubscriptionId(Id(json)) : null;

  @override
  String? toJson(FirebaseSubscriptionId? object) => object?.id.value;
}

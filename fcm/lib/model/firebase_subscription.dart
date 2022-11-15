
import 'package:equatable/equatable.dart';
import 'package:fcm/converter/device_client_id_nullable_converter.dart';
import 'package:fcm/converter/firebase_expired_time_nullable_converter.dart';
import 'package:fcm/converter/firebase_subscription_id_nullable_converter.dart';
import 'package:fcm/converter/firebase_token_nullable_converter.dart';
import 'package:fcm/converter/type_name_converter.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_expired_time.dart';
import 'package:fcm/model/firebase_subscription_id.dart';
import 'package:fcm/model/firebase_token.dart';
import 'package:fcm/model/type_name.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_subscription.g.dart';

@DeviceClientIdNullableConverter()
@FirebaseSubscriptionIdNullableConverter()
@FirebaseTokenNullableConverter()
@FirebaseExpiredTimeNullableConverter()
@TypeNameConverter()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FirebaseSubscription with EquatableMixin {

  final FirebaseSubscriptionId? id;
  final FirebaseToken? token;
  final DeviceClientId? deviceClientId;
  final FirebaseExpiredTime? expires;
  final List<TypeName>? types;

  FirebaseSubscription({
    this.id,
    this.token,
    this.deviceClientId,
    this.expires,
    this.types
  });

  factory FirebaseSubscription.fromJson(Map<String, dynamic> json) => _$FirebaseSubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseSubscriptionToJson(this);

  @override
  List<Object?> get props => [id, token, deviceClientId, expires, types];
}

import 'package:equatable/equatable.dart';
import 'package:fcm/converter/device_client_id_nullable_converter.dart';
import 'package:fcm/converter/firebase_registration_expired_time_nullable_converter.dart';
import 'package:fcm/converter/firebase_registration_id_nullable_converter.dart';
import 'package:fcm/converter/fcm_token_nullable_converter.dart';
import 'package:fcm/converter/type_name_converter.dart';
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_registration_expired_time.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:fcm/model/fcm_token.dart';
import 'package:fcm/model/type_name.dart';
import 'package:json_annotation/json_annotation.dart';

part 'firebase_registration.g.dart';

@DeviceClientIdNullableConverter()
@FirebaseRegistrationIdNullableConverter()
@FcmTokenNullableConverter()
@FirebaseRegistrationExpiredTimeNullableConverter()
@TypeNameConverter()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class FirebaseRegistration with EquatableMixin {

  final FirebaseRegistrationId? id;
  final FcmToken? token;
  final DeviceClientId? deviceClientId;
  final FirebaseRegistrationExpiredTime? expires;
  final List<TypeName>? types;

  FirebaseRegistration({
    this.id,
    this.token,
    this.deviceClientId,
    this.expires,
    this.types
  });

  factory FirebaseRegistration.fromJson(Map<String, dynamic> json) => _$FirebaseRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseRegistrationToJson(this);

  @override
  List<Object?> get props => [id, token, deviceClientId, expires, types];
}
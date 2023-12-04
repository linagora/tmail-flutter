import 'package:fcm/converter/device_client_id_nullable_converter.dart';
import 'package:fcm/converter/fcm_token_nullable_converter.dart';
import 'package:fcm/converter/firebase_registration_id_nullable_converter.dart';
import 'package:fcm/converter/type_name_converter.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_expired_time.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_registration_cache.dart';

extension FirebaseRegistrationCacheExtension on FirebaseRegistrationCache {
  FirebaseRegistration toFirebaseRegistration() {
    return FirebaseRegistration(
      id: const FirebaseRegistrationIdNullableConverter().fromJson(id),
      token: const FcmTokenNullableConverter().fromJson(token),
      deviceClientId: const DeviceClientIdNullableConverter().fromJson(deviceClientId),
      expires: expires != null ? FirebaseRegistrationExpiredTime(UTCDate(expires!)) : null,
      types: types?.map((type) => const TypeNameConverter().fromJson(type)).toList()
    );
  }
}

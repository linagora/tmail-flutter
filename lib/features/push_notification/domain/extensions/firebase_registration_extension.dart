
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/fcm_token.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/type_name.dart';

extension FirebaseRegistrationExtension on FirebaseRegistration {

  FirebaseRegistration syncProperties({
    DeviceClientId? newDeviceId,
    FcmToken? newFcmToken,
    List<TypeName>? newTypes,
  }) {
    return FirebaseRegistration(
      id: id,
      token: newFcmToken ?? token,
      deviceClientId: newDeviceId ?? deviceClientId,
      expires: expires,
      types: newTypes ?? types
    );
  }
}
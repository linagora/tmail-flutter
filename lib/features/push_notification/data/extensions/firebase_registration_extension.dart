import 'package:fcm/model/firebase_registration.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_registration_cache.dart';

extension FirebaseRegistrationExtension on FirebaseRegistration {
  FirebaseRegistrationCache toFirebaseRegistrationCache() {
    return FirebaseRegistrationCache(
      deviceClientId: deviceClientId!.value,
      id: id?.id.value,
      token: token?.value,
      expires: expires?.value.value,
      types: types?.map((type) => type.value).toList(),
    );
  }
}

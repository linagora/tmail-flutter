
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_subscription.dart';

extension FirebaseSubscriptionExtension on FirebaseSubscription {

  FirebaseSubscription fromDeviceId({DeviceClientId? newDeviceId}) {
    return FirebaseSubscription(
      id: id,
      token: token,
      deviceClientId: newDeviceId ?? deviceClientId,
      expires: expires,
      types: types
    );
  }
}
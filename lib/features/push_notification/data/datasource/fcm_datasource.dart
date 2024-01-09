
import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';

abstract class FCMDatasource {
  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState);

  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName);

  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName);

  Future<void> storeFirebaseRegistration(AccountId accountId, UserName userName, FirebaseRegistration firebaseRegistration);

  Future<FirebaseRegistration> getFirebaseRegistrationByDeviceId(DeviceClientId deviceId);

  Future<FirebaseRegistration> registerNewFirebaseRegistrationToken(RegisterNewTokenRequest newTokenRequest);

  Future<FirebaseRegistration> getStoredFirebaseRegistration(AccountId accountId, UserName userName);

  Future<void> deleteFirebaseRegistrationCache(AccountId accountId, UserName userName);

  Future<void> destroyFirebaseRegistration(FirebaseRegistrationId registrationId);

  Future<void> updateFirebaseRegistrationToken(UpdateTokenExpiredTimeRequest expiredTimeRequest);
}
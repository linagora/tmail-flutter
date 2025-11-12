import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/fcm_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/extensions/firebase_registration_extension.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class FcmDatasourceImpl extends FCMDatasource {

  final FcmApi _fcmApi;
  final ExceptionThrower _exceptionThrower;

  FcmDatasourceImpl(this._fcmApi, this._exceptionThrower);

  @override
  Future<FirebaseRegistration> getFirebaseRegistrationByDeviceId(DeviceClientId deviceId) {
    return Future.sync(() async {
      return await _fcmApi.getFirebaseRegistrationByDeviceId(deviceId);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<bool> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) {
    throw UnimplementedError();
  }

  @override
  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) {
    throw UnimplementedError();
  }

  @override
  Future<bool> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) {
    throw UnimplementedError();
  }

  @override
  Future<FirebaseRegistration> registerNewFirebaseRegistrationToken(RegisterNewTokenRequest newTokenRequest) {
    return Future.sync(() async {
      final registrationCreated = await _fcmApi.registerNewFirebaseRegistrationToken(newTokenRequest);
      return registrationCreated.syncProperties(
        newDeviceId: newTokenRequest.firebaseRegistration.deviceClientId,
        newFcmToken: newTokenRequest.firebaseRegistration.token,
        newTypes: newTokenRequest.firebaseRegistration.types,
      );
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
  
  @override
  Future<bool> storeFirebaseRegistration(FirebaseRegistration firebaseRegistration) {
    throw UnimplementedError();
  }
  
  @override
  Future<FirebaseRegistration> getStoredFirebaseRegistration() {
    throw UnimplementedError();
  }

  @override
  Future<void> destroyFirebaseRegistration(FirebaseRegistrationId registrationId) {
    return Future.sync(() async {
      return await _fcmApi.destroyFirebaseRegistration(registrationId);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> updateFirebaseRegistrationToken(UpdateTokenExpiredTimeRequest expiredTimeRequest) {
    return Future.sync(() async {
      return await _fcmApi.updateFirebaseRegistrationToken(expiredTimeRequest);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<void> deleteFirebaseRegistrationCache() {
    throw UnimplementedError();
  }
}
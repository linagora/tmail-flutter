import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/firebase_registration_cache_extension.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/firebase_registration_extension.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CacheFCMDatasourceImpl extends FCMDatasource {

  final FCMCacheManager _firebaseCacheManager;
  final ExceptionThrower _exceptionThrower;

  CacheFCMDatasourceImpl(this._firebaseCacheManager, this._exceptionThrower);

  @override
  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) {
    return Future.sync(() async {
      return await _firebaseCacheManager.storeStateToRefresh(accountId, userName, typeName, newState);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<jmap.State> getStateToRefresh(AccountId accountId,UserName userName, TypeName typeName) {
    return Future.sync(() async {
      return await _firebaseCacheManager.getStateToRefresh(accountId, userName, typeName);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) {
    return Future.sync(() async {
      return await _firebaseCacheManager.deleteStateToRefresh(accountId, userName, typeName);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<FirebaseRegistration> getFirebaseRegistrationByDeviceId(DeviceClientId deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<FirebaseRegistration> registerNewFirebaseRegistrationToken(RegisterNewTokenRequest newTokenRequest) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> storeFirebaseRegistration(
    AccountId accountId,
    UserName userName,
    FirebaseRegistration firebaseRegistration
  ) {
   return Future.sync(() async {
      return await _firebaseCacheManager.storeFirebaseRegistration(
        accountId,
        userName,
        firebaseRegistration.toFirebaseRegistrationCache()
      );
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<FirebaseRegistration> getStoredFirebaseRegistration(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final firebaseRegistrationCache = await _firebaseCacheManager.getStoredFirebaseRegistration(accountId, userName);
      return firebaseRegistrationCache.toFirebaseRegistration();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> destroyFirebaseRegistration(FirebaseRegistrationId registrationId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateFirebaseRegistrationToken(UpdateTokenExpiredTimeRequest expiredTimeRequest) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFirebaseRegistrationCache(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      return await _firebaseCacheManager.deleteFirebaseRegistration(accountId, userName);
    }).catchError(_exceptionThrower.throwException);
  }
}
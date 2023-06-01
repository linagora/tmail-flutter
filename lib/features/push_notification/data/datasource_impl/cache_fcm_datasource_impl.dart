import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
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
  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> storeSubscription(FCMSubscriptionCache fcmSubscriptionCache) {
   return Future.sync(() async {
      return await _firebaseCacheManager.storeSubscription(fcmSubscriptionCache);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<FCMSubscriptionCache> geSubscription() {
    return Future.sync(() async {
      return await _firebaseCacheManager.getSubscription();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> destroySubscription(String subscriptionId) {
    throw UnimplementedError();
  }
}
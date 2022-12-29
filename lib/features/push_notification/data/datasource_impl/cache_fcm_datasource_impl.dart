import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
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
  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState) {
    return Future.sync(() async {
      return await _firebaseCacheManager.storeStateToRefresh(typeName, newState);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<jmap.State> getStateToRefresh(TypeName typeName) {
    return Future.sync(() async {
      return await _firebaseCacheManager.getStateToRefresh(typeName);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> deleteStateToRefresh(TypeName typeName) {
    return Future.sync(() async {
      return await _firebaseCacheManager.deleteStateToRefresh(typeName);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
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
    }).catchError((error) {
       _exceptionThrower.throwException(error);
    });
  }
  
  @override
  Future<FCMSubscriptionCache> geSubscription() {
    return Future.sync(() async {
      return await _firebaseCacheManager.getSubscription();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}
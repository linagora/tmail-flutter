import 'package:core/utils/app_logger.dart';
import 'package:fcm/model/type_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/caching/subscription_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class FCMCacheManager {
  final SharedPreferences _sharedPreferences;
  final FCMSubscriptionCacheClient _fcmSubscriptionCacheClient;


  FCMCacheManager(this._sharedPreferences,this._fcmSubscriptionCacheClient);

  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState) {
    return _sharedPreferences.setString(typeName.value, newState.value);
  }

  Future<jmap.State> getStateToRefresh(TypeName typeName) async {
    log('FCMCacheManager::getStoredFcmStateChange():keys_BEFORE: ${_sharedPreferences.getKeys().toString()}');
    await _sharedPreferences.reload();
    log('FCMCacheManager::getStoredFcmStateChange():keys_AFTER: ${_sharedPreferences.getKeys().toString()}');
    final stateValue = _sharedPreferences.getString(typeName.value);
    if (stateValue != null) {
      return jmap.State(stateValue);
    } else {
      if (typeName == TypeName.emailDelivery) {
        throw NotFoundEmailDeliveryStateException();
      } else {
        throw NotFoundStateToRefreshException();
      }
    }
  }

  Future<bool> deleteStateToRefresh(TypeName typeName) {
    return _sharedPreferences.remove(typeName.value);
  }

  Future<bool> clearAllStateToRefresh() async {
    return await Future.wait([
      _sharedPreferences.remove(TypeName.emailType.value),
      _sharedPreferences.remove(TypeName.mailboxType.value),
      _sharedPreferences.remove(TypeName.emailDelivery.value),
    ]).then((listResult) => listResult.every((result) => result));
  }

  Future<void> storeSubscription(FCMSubscriptionCache fcmSubscriptionCache) {
    return _fcmSubscriptionCacheClient.insertItem(
        FCMSubscriptionCache.keyCacheValue, fcmSubscriptionCache);
  }
  
  Future<FCMSubscriptionCache> getSubscription() async {
    final _fcmSubscription = await _fcmSubscriptionCacheClient.getItem(FCMSubscriptionCache.keyCacheValue);
    if (_fcmSubscription == null) {
      throw NotFoundSubscriptionException();
    } else {
      return _fcmSubscription;
    }
  }
}
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/subscription_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class FCMCacheManager {
  final FcmCacheClient _fcmCacheClient;
  final FCMSubscriptionCacheClient _fcmSubscriptionCacheClient;

  FCMCacheManager(this._fcmCacheClient,this._fcmSubscriptionCacheClient);

  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) {
    final stateKeyCache = TupleKey(typeName.value, accountId.asString, userName.value).encodeKey;
    return _fcmCacheClient.insertItem(stateKeyCache, newState.value);
  }

  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) async {
    final stateKeyCache = TupleKey(typeName.value, accountId.asString, userName.value).encodeKey;
    final stateValue = await _fcmCacheClient.getItem(stateKeyCache);
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

  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) {
    final stateKeyCache = TupleKey(typeName.value, accountId.asString, userName.value).encodeKey;
    return _fcmCacheClient.deleteItem(stateKeyCache);
  }

  Future<void> clearAllStateToRefresh() async {
    return _fcmCacheClient.clearAllData();
  }

  Future<void> storeSubscription(FCMSubscriptionCache fcmSubscriptionCache) {
    return _fcmSubscriptionCacheClient.insertItem(
        FCMSubscriptionCache.keyCacheValue, fcmSubscriptionCache);
  }
  
  Future<FCMSubscriptionCache> getSubscription() async {
    final fcmSubscription = await _fcmSubscriptionCacheClient.getItem(FCMSubscriptionCache.keyCacheValue);
    if (fcmSubscription == null) {
      throw NotFoundSubscriptionException();
    } else {
      return fcmSubscription;
    }
  }
}
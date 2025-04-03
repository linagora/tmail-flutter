import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/firebase_registration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_registration_cache.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';

class FCMCacheManager {
  final FcmCacheClient _fcmCacheClient;
  final FirebaseRegistrationCacheClient _firebaseRegistrationCacheClient;

  FCMCacheManager(this._fcmCacheClient,this._firebaseRegistrationCacheClient);

  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) {
    final stateKeyCache = TupleKey(typeName.value, accountId.asString, userName.value).encodeKey;
    return _fcmCacheClient.insertItem(stateKeyCache, newState.value);
  }

  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) async {
    final stateKeyCache = TupleKey(typeName.value, accountId.asString, userName.value).encodeKey;
    final stateValue = await _fcmCacheClient.getItem(stateKeyCache, needToReopen: true);
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

  Future<void> storeFirebaseRegistration(FirebaseRegistrationCache firebaseRegistrationCache) {
    return _firebaseRegistrationCacheClient.insertItem(
      FirebaseRegistrationCache.keyCacheValue,
      firebaseRegistrationCache
    );
  }
  
  Future<FirebaseRegistrationCache> getStoredFirebaseRegistration() async {
    final firebaseRegistration = await _firebaseRegistrationCacheClient.getItem(FirebaseRegistrationCache.keyCacheValue, needToReopen: true);
    if (firebaseRegistration == null) {
      throw NotFoundFirebaseRegistrationCacheException();
    } else {
      return firebaseRegistration;
    }
  }

  Future<void> deleteFirebaseRegistration() async {
    await _firebaseRegistrationCacheClient.deleteItem(FirebaseRegistrationCache.keyCacheValue);
  }

  Future<void> clearAllEmailState(
    AccountId accountId,
    Session session,
  ) async {
    await deleteStateToRefresh(
      accountId,
      session.username,
      TypeName.emailDelivery,
    );
    await deleteStateToRefresh(
      accountId,
      session.username,
      TypeName.emailType,
    );
  }
}
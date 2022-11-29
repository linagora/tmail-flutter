import 'package:core/utils/app_logger.dart';
import 'package:fcm/model/type_name.dart';
import 'package:model/fcm/fcm_token_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/caching/fcm_token_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/fcm_cache_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/fcm_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class FCMCacheManager {
  final FcmTokenCacheClient _fcmTokenCacheClient;
  final SharedPreferences _sharedPreferences;

  static const String fcmDeviceIdKey = 'FCM_DEVICE_ID';

  FCMCacheManager(this._fcmTokenCacheClient, this._sharedPreferences);

  Future<FCMTokenDto> getFCMToken(String accountId) async {
    try {
      final firebase = await _fcmTokenCacheClient.getItem(accountId);
      if(firebase != null ) {
        return firebase.toFCMDto();
      } else {
        throw NotFoundStoredFCMException();
      }
    } catch (e) {
      logError('FCMCacheManager::getFCM(): $e');
      throw NotFoundStoredFCMException();
    }
  }

  Future<void> setFCMToken(FCMTokenDto firebaseDto) {
    log('FCMCacheManager::setFCM(): $_fcmTokenCacheClient');
    return _fcmTokenCacheClient.insertItem(firebaseDto.accountId, firebaseDto.toCache());
  }

  Future<void> deleteFCMToken(String accountId) {
    log('FCMCacheManager::deleteSelectedFCM(): $accountId');
    return _fcmTokenCacheClient.deleteItem(accountId);
  }

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
      _sharedPreferences.remove(TypeName.emailDelivery.value)
    ]).then((listResult) => listResult.every((result) => result));
  }

  Future<bool> storeDeviceId(String deviceId) {
    return _sharedPreferences.setString(fcmDeviceIdKey, deviceId);
  }
}
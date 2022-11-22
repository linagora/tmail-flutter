import 'package:core/utils/app_logger.dart';
import 'package:model/fcm/fcm_token_dto.dart';
import 'package:tmail_ui_user/features/caching/fcm_token_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/fcm_cache_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/fcm_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';

class FCMCacheManager {
  final FcmTokenCacheClient _fcmTokenCacheClient;

  FCMCacheManager(this._fcmTokenCacheClient);

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
}
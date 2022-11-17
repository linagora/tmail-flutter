import 'package:core/utils/app_logger.dart';
import 'package:model/firebase/firebase_dto.dart';
import 'package:tmail_ui_user/features/caching/firebase_config_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/firebase_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_cache.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/firebase_cache_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/firebase_exception.dart';

class FirebaseCacheManager {
  final FirebaseCacheClient _firebaseCacheClient;

  FirebaseCacheManager(this._firebaseCacheClient);

  Future<FirebaseDto> getFirebase() async {
    try {
      final firebase = await _firebaseCacheClient.getItem(FirebaseCache.keyCacheValue);
      if(firebase != null ) {
        return firebase.toFirebaseDto();
      } else {
        throw NotFoundStoredFirebaseException();
      }
    } catch (e) {
      logError('FirebaseCacheManager::getFirebase(): $e');
      throw NotFoundStoredFirebaseException();
    }
  }

  Future<void> setFirebase(FirebaseDto firebaseDto) {
    log('FirebaseCacheManager::setFirebase(): $_firebaseCacheClient');
    return _firebaseCacheClient.insertItem(firebaseDto.token, firebaseDto.toCache());
  }

  Future<void> deleteFirebase(String token) {
    log('FirebaseCacheManager::deleteSelectedFirebase(): $token');
    return _firebaseCacheClient.deleteItem(token);
  }
}
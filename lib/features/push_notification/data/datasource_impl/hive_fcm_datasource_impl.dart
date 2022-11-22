import 'package:model/fcm/fcm_token_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/local/fcm_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveFCMDatasourceImpl extends FCMDatasource {

  final FCMCacheManager _firebaseCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveFCMDatasourceImpl(this._firebaseCacheManager, this._exceptionThrower);

  @override
  Future<FCMTokenDto> getFCMToken(String accountId) {
    return Future.sync(() async {
      return await _firebaseCacheManager.getFCMToken(accountId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> setFCMToken(FCMTokenDto fcmToken) {
    return Future.sync(() async {
      return await _firebaseCacheManager.setFCMToken(fcmToken);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> deleteFCMToken(String accountId) {
    return Future.sync(() async {
      return await _firebaseCacheManager.deleteFCMToken(accountId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}
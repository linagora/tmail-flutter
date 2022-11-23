import 'package:core/utils/app_logger.dart';
import 'package:model/fcm/fcm_token_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';

class FCMRepositoryImpl extends FCMRepository {

  final FCMDatasource _fcmDatasource;

  FCMRepositoryImpl(this._fcmDatasource);

  @override
  Future<FCMTokenDto> getFCMToken(String accountId) {
    return _fcmDatasource.getFCMToken(accountId);
  }

  @override
  Future<void> setFCMToken(FCMTokenDto fcmTokenDto) {
    log('FCMRepositoryImpl::setFCMToken(): $fcmTokenDto');
    return _fcmDatasource.setFCMToken(fcmTokenDto);
  }

  @override
  Future<void> deleteFCMToken(String accountId) {
    return _fcmDatasource.deleteFCMToken(accountId);
  }
}
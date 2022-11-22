
import 'package:model/fcm/fcm_token_dto.dart';

abstract class FCMDatasource {
  Future<FCMTokenDto> getFCMToken(String accountId);

  Future<void> setFCMToken(FCMTokenDto fcmToken);

  Future<void> deleteFCMToken(String accountId);
}
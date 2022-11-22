import 'package:model/fcm/fcm_token_dto.dart';

abstract class FCMRepository {
  Future<FCMTokenDto> getFCMToken(String accountId);

  Future<void> setFCMToken(FCMTokenDto fcmTokenDto);

  Future<void> deleteFCMToken(String accountId);
}
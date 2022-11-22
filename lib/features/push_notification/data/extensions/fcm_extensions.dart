import 'package:model/fcm/fcm_token_dto.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_token_cache.dart';

extension FCMExtensions on FCMTokenDto {
  FCMTokenCache toCache() {
    return FCMTokenCache(
      token,
      accountId,
    );
  }
}

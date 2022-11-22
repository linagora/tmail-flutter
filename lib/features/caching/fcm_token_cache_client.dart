import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_token_cache.dart';

class FcmTokenCacheClient extends HiveCacheClient<FCMTokenCache> {

  @override
  String get tableName => 'FCMTokenCache';
}
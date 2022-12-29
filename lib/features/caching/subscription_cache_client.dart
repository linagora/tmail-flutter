
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';

class FCMSubscriptionCacheClient extends HiveCacheClient<FCMSubscriptionCache> {

  @override
  String get tableName => 'FCMSubscriptionCache';
}
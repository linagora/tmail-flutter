
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

class DetailedEmailHiveCacheClient extends HiveCacheClient<DetailedEmailHiveCache> {

  @override
  String get tableName => CachingConstants.incomingEmailedCacheBoxName;
}
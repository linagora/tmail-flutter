
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

class EmailCacheClient extends HiveCacheClient<EmailCache> {

  @override
  String get tableName => CachingConstants.emailCacheBoxName;
}
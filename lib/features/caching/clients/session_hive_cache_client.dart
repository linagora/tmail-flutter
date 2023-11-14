
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/home/data/model/session_hive_obj.dart';

class SessionHiveCacheClient extends HiveCacheClient<SessionHiveObj> {

  @override
  String get tableName => CachingConstants.sessionCacheBoxName;

  @override
  bool get encryption => true;
}
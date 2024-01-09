
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';

class StateCacheClient extends HiveCacheClient<StateCache> {

  @override
  String get tableName => CachingConstants.stateCacheBoxName;
}
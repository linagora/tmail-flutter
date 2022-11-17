import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/firebase_cache.dart';

class FirebaseCacheClient extends HiveCacheClient<FirebaseCache> {

  @override
  String get tableName => 'FirebaseCache';
}
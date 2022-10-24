import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';

class EncryptionKeyCacheClient extends HiveCacheClient<EncryptionKeyCache> {

  @override
  String get tableName => 'EncryptionKeyCache';
}
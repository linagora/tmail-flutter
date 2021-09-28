import 'dart:io';

import 'package:hive/hive.dart';
import 'package:model/caching/mailbox/mailbox_rights_cache.dart';
import 'package:model/model.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:tmail_ui_user/features/caching/config/cache_config.dart';

class HiveCacheConfig extends CacheConfig {

  Future setUp() async {
    await initializeDatabase();
    registerAdapter();
  }

  @override
  Future initializeDatabase() async {
    Directory directory = await pathProvider.getApplicationDocumentsDirectory();
    Hive.init(directory.path);
  }

  @override
  void registerAdapter() {
    Hive.registerAdapter(MailboxCacheAdapter());
    Hive.registerAdapter(MailboxRightsCacheAdapter());
    Hive.registerAdapter(StateDaoAdapter());
    Hive.registerAdapter(StateTypeAdapter());
  }
}
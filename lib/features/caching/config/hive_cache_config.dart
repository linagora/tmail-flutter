import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';

class HiveCacheConfig {

  Future setUp() async {
    await initializeDatabase();
    registerAdapter();
  }

  Future initializeDatabase() async {
    Directory directory = await pathProvider.getApplicationDocumentsDirectory();
    Hive.init(directory.path);
  }

  void registerAdapter() {
    Hive.registerAdapter(MailboxCacheAdapter());
    Hive.registerAdapter(MailboxRightsCacheAdapter());
    Hive.registerAdapter(StateCacheAdapter());
    Hive.registerAdapter(StateTypeAdapter());
  }
}
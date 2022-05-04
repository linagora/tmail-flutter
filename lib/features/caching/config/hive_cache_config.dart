import 'dart:io';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_rights_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_address_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

class HiveCacheConfig {

  Future setUp({String? cachePath}) async {
    await initializeDatabase(databasePath: cachePath);
    registerAdapter();
  }

  Future initializeDatabase({String? databasePath}) async {
    if (databasePath != null) {
      Hive.init(databasePath);
    } else {
      if (!GetPlatform.isWeb) {
        Directory directory = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(directory.path);
      }
    }
  }

  void registerAdapter() {
    Hive.registerAdapter(MailboxCacheAdapter());
    Hive.registerAdapter(MailboxRightsCacheAdapter());
    Hive.registerAdapter(StateCacheAdapter());
    Hive.registerAdapter(StateTypeAdapter());
    Hive.registerAdapter(EmailAddressHiveCacheAdapter());
    Hive.registerAdapter(EmailCacheAdapter());
  }
}

import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';

class LocalBindings extends Bindings {

  @override
  void dependencies() {
    _bindingDatabase();
    _bindingCaching();
  }

  void _bindingDatabase() {
    Get.put(DatabaseClient());
  }

  void _bindingCaching() {
    Get.put(MailboxCacheClient());
    Get.put(StateCacheClient());
    Get.put(MailboxCacheManager(Get.find<MailboxCacheClient>()));
  }
}
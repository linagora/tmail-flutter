
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';

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
    Get.put(EmailCacheClient());
    Get.put(EmailCacheManager(Get.find<EmailCacheClient>()));
    Get.put(CachingManager(
      Get.find<MailboxCacheClient>(),
      Get.find<StateCacheClient>(),
      Get.find<EmailCacheClient>()));
  }
}
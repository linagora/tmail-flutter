import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_persistent_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

class MobileMailboxDashboardBindings extends MailboxDashBoardBindings {
  MobileMailboxDashboardBindings() : super.base();

  @override
  void bindPlatformDatasourceImpl() {
    Get.lazyPut(() => ComposerHiveCacheClient());
    Get.lazyPut(
      () => ComposerPersistentCacheDatasourceImpl(
        Get.find<ComposerHiveCacheClient>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
  }

  @override
  void bindPlatformDatasource() {
    Get.lazyPut<ComposerCacheDatasource>(
      () => Get.find<ComposerPersistentCacheDatasourceImpl>(),
    );
  }
}

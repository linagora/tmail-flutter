import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_persistent_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

class MobileComposerBindings extends ComposerBindings {
  MobileComposerBindings({String? composerId, ComposerArguments? composerArguments})
      : super.base(composerId: composerId, composerArguments: composerArguments);

  @override
  void bindPlatformCacheDatasourceImpl() {
    Get.lazyPut(() => ComposerHiveCacheClient(), tag: composerId);
    Get.lazyPut(() => ComposerPersistentCacheDatasourceImpl(
      Get.find<ComposerHiveCacheClient>(tag: composerId),
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
  }

  @override
  void bindPlatformComposerCacheDatasource() {
    Get.lazyPut<ComposerCacheDatasource>(
      () => Get.find<ComposerPersistentCacheDatasourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindPlatformRichTextController() {
    Get.lazyPut(() => RichTextMobileTabletController(), tag: composerId);
  }

  @override
  void disposePlatformRichTextController() {
    Get.delete<RichTextMobileTabletController>(tag: composerId);
  }

  @override
  void disposePlatformCacheImpl() {
    Get.delete<ComposerHiveCacheClient>(tag: composerId);
    Get.delete<ComposerPersistentCacheDatasourceImpl>(tag: composerId);
  }
}

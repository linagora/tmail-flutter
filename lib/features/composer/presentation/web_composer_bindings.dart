import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/web_composer_reload_cache_handler.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/web_composer_reload_snapshot_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_session_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_reload_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_reload_cache_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

class WebComposerBindings extends ComposerBindings {
  WebComposerBindings({String? composerId, ComposerArguments? composerArguments})
      : super.base(composerId: composerId, composerArguments: composerArguments);

  @override
  void bindPlatformCacheDatasourceImpl() {
    Get.lazyPut(() => ComposerSessionCacheDatasourceImpl(
      Get.find<CacheExceptionThrower>(),
    ), tag: composerId);
  }

  @override
  void bindPlatformComposerCacheDatasource() {
    Get.lazyPut<ComposerCacheDatasource>(
      () => Get.find<ComposerSessionCacheDatasourceImpl>(tag: composerId),
      tag: composerId,
    );
  }

  @override
  void bindPlatformRichTextController() {
    Get.lazyPut(() => RichTextWebController(), tag: composerId);
  }

  @override
  void registerPlatformReloadCacheHandler(ComposerController controller) {
    controller.registerReloadCacheAction(
      WebComposerReloadCacheHandler(
        WebComposerReloadSnapshotBuilder(controller).build,
        SaveComposerReloadCacheInteractor(
          ComposerReloadCacheRepositoryImpl(
            Get.find<ComposerSessionCacheDatasourceImpl>(tag: composerId),
          ),
        ),
      ).saveBeforeUnload,
    );
  }

  @override
  void disposePlatformRichTextController() {
    Get.delete<RichTextWebController>(tag: composerId);
  }

  @override
  void disposePlatformCacheImpl() {
    Get.delete<ComposerSessionCacheDatasourceImpl>(tag: composerId);
  }
}

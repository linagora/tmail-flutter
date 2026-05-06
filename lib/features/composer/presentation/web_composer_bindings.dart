import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_session_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/cache_exception_thrower.dart';

class WebComposerBindings extends ComposerBindings {
  WebComposerBindings({String? composerId, ComposerArguments? composerArguments})
      : super.base(composerId: composerId, composerArguments: composerArguments);

  @override
  void bindPlatformCacheDatasourceImpl() {
    Get.lazyPut(() => ComposerSessionCacheDatasourceImpl(
      Get.find<HtmlTransform>(),
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
  void disposePlatformRichTextController() {
    Get.delete<RichTextWebController>(tag: composerId);
  }

  @override
  void disposePlatformCacheImpl() {}
}

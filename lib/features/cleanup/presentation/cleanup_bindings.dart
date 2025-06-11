
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource_impl/cleanup_datasource_impl.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_username_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/repository/cleanup_repository_impl.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_url_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_username_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class CleanupBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<CleanupDataSource>(() => Get.find<CleanupDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => CleanupDataSourceImpl(
      Get.find<EmailCacheManager>(),
      Get.find<RecentSearchCacheManager>(),
      Get.find<RecentLoginUrlCacheManager>(),
      Get.find<RecentLoginUsernameCacheManager>(),
      Get.find<CacheExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => CleanupEmailCacheInteractor(Get.find<CleanupRepository>()));
    Get.lazyPut(() => CleanupRecentSearchCacheInteractor(Get.find<CleanupRepository>()));
    Get.lazyPut(() => CleanupRecentLoginUrlCacheInteractor(Get.find<CleanupRepository>()));
    Get.lazyPut(() => CleanupRecentLoginUsernameCacheInteractor(Get.find<CleanupRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<CleanupRepository>(() => Get.find<CleanupRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => CleanupRepositoryImpl(Get.find<CleanupDataSource>()));
  }
}
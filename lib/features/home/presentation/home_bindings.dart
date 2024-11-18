import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
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
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => HomeController(
      Get.find<CleanupEmailCacheInteractor>(),
      Get.find<EmailReceiveManager>(),
      Get.find<CleanupRecentSearchCacheInteractor>(),
      Get.find<CleanupRecentLoginUrlCacheInteractor>(),
      Get.find<CleanupRecentLoginUsernameCacheInteractor>(),
    ));
  }

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
    Get.lazyPut(() => CheckOIDCIsAvailableInteractor(Get.find<AuthenticationOIDCRepository>()));
    if (PlatformInfo.isMobile) {
      Get.lazyPut(() => AutoSignInViaDeepLinkInteractor(
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<AccountRepository>(),
        Get.find<CredentialRepository>(),
      ));
    }
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
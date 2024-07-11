import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_login_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/login_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_service.dart';
import 'package:tmail_ui_user/features/login/data/repository/login_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/dns_lookup_to_get_jmap_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_auth_response_url_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class LoginBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.create(() => LoginController(
      Get.find<AuthenticationInteractor>(),
      Get.find<CheckOIDCIsAvailableInteractor>(),
      Get.find<GetTokenOIDCInteractor>(),
      Get.find<AuthenticateOidcOnBrowserInteractor>(),
      Get.find<GetAuthResponseUrlBrowserInteractor>(),
      Get.find<SaveLoginUrlOnMobileInteractor>(),
      Get.find<GetAllRecentLoginUrlOnMobileInteractor>(),
      Get.find<SaveLoginUsernameOnMobileInteractor>(),
      Get.find<GetAllRecentLoginUsernameOnMobileInteractor>(),
      Get.find<DNSLookupToGetJmapUrlInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<LoginDataSource>(() => Get.find<LoginDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => HiveLoginDataSourceImpl(
      Get.find<RecentLoginUrlCacheClient>(),
      Get.find<RecentLoginUsernameCacheClient>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => LoginDataSourceImpl(
      Get.find<DNSService>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => CheckOIDCIsAvailableInteractor(
        Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetTokenOIDCInteractor(
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<AccountRepository>()
    ));
    Get.lazyPut(() => GetAuthResponseUrlBrowserInteractor(
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => AuthenticateOidcOnBrowserInteractor(
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => SaveLoginUrlOnMobileInteractor(Get.find<LoginRepository>(),));
    Get.lazyPut(() => GetAllRecentLoginUrlOnMobileInteractor(Get.find<LoginRepository>()));
    Get.lazyPut(() => SaveLoginUsernameOnMobileInteractor(Get.find<LoginRepository>(),));
    Get.lazyPut(() => GetAllRecentLoginUsernameOnMobileInteractor(Get.find<LoginRepository>()));
    Get.lazyPut(() => DNSLookupToGetJmapUrlInteractor(Get.find<LoginRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<LoginRepository>(() => Get.find<LoginRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => LoginRepositoryImpl(
      {
        DataSourceType.hiveCache: Get.find<HiveLoginDataSourceImpl>(),
        DataSourceType.network: Get.find<LoginDataSource>(),
      }
    ));
  }
}
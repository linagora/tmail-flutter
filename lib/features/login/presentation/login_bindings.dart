import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_url_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_username_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/login_url_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/login_username_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/login_url_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/login_username_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_url_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_username_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class LoginBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.create(() => LoginController(
      Get.find<AuthenticationInteractor>(),
      Get.find<CheckOIDCIsAvailableInteractor>(),
      Get.find<GetOIDCIsAvailableInteractor>(),
      Get.find<GetOIDCConfigurationInteractor>(),
      Get.find<GetTokenOIDCInteractor>(),
      Get.find<AuthenticateOidcOnBrowserInteractor>(),
      Get.find<GetAuthenticationInfoInteractor>(),
      Get.find<GetStoredOidcConfigurationInteractor>(),
      Get.find<SaveLoginUrlOnMobileInteractor>(),
      Get.find<GetAllRecentLoginUrlOnMobileInteractor>(),
      Get.find<SaveLoginUsernameOnMobileInteractor>(),
      Get.find<GetAllRecentLoginUsernameOnMobileInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<LoginUrlDataSource>(() => Get.find<LoginUrlDataSourceImpl>());
    Get.lazyPut<LoginUsernameDataSource>(() => Get.find<LoginUsernameDataSourceImpl>());

  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => LoginUrlDataSourceImpl(
      Get.find<RecentLoginUrlCacheClient>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => LoginUsernameDataSourceImpl(
      Get.find<RecentLoginUsernameCacheClient>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => CheckOIDCIsAvailableInteractor(
        Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetOIDCIsAvailableInteractor(
        Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetOIDCConfigurationInteractor(
        Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetTokenOIDCInteractor(
        Get.find<CredentialRepository>(),
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<AccountRepository>()
    ));
    Get.lazyPut(() => AuthenticateOidcOnBrowserInteractor(
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetAuthenticationInfoInteractor(
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetStoredOidcConfigurationInteractor(
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => SaveLoginUrlOnMobileInteractor(
      Get.find<LoginUrlRepository>(),
    ));
    Get.lazyPut(() => GetAllRecentLoginUrlOnMobileInteractor(Get.find<LoginUrlRepository>()));
    Get.lazyPut(() => SaveLoginUsernameOnMobileInteractor(
      Get.find<LoginUsernameRepository>(),
    ));
    Get.lazyPut(() => GetAllRecentLoginUsernameOnMobileInteractor(
      Get.find<LoginUsernameRepository>()
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<LoginUrlRepository>(() => Get.find<LoginUrlRepositoryImpl>());
    Get.lazyPut<LoginUsernameRepository>(() => Get.find<LoginUsernameRepositoryImpl>());

  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => LoginUrlRepositoryImpl(Get.find<LoginUrlDataSource>()));
    Get.lazyPut(() => LoginUsernameRepositoryImpl(Get.find<LoginUsernameDataSource>()));
  }
}
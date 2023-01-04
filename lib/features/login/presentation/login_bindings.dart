import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_url_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_username_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/login_url_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/login_username_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/login_url_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/login_username_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_url_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_username_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class LoginBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => LoginController(
        Get.find<LogoutOidcInteractor>(),
        Get.find<DeleteAuthorityOidcInteractor>(),
        Get.find<GetAuthenticatedAccountInteractor>(),
        Get.find<UpdateAuthenticationAccountInteractor>(),
        Get.find<AuthenticationInteractor>(),
        Get.find<DynamicUrlInterceptors>(),
        Get.find<AuthorizationInterceptors>(),
        Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag),
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
    Get.lazyPut<AuthenticationDataSource>(() => Get.find<AuthenticationDataSourceImpl>());
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
    Get.lazyPut<LoginUrlDataSource>(() => Get.find<LoginUrlDataSourceImpl>());
    Get.lazyPut<LoginUsernameDataSource>(() => Get.find<LoginUsernameDataSourceImpl>());

  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AuthenticationDataSourceImpl());
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
      Get.find<OIDCHttpClient>(),
      Get.find<AuthenticationClientBase>(),
      Get.find<TokenOidcCacheManager>(),
      Get.find<OidcConfigurationCacheManager>(),
      Get.find<RemoteExceptionThrower>()
    ));
    Get.lazyPut(() => HiveAccountDatasourceImpl(
      Get.find<AccountCacheManager>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => LoginUrlDataSourceImpl(
      Get.find<RecentLoginUrlCacheClient>(),
      Get.find<CacheExceptionThrower>()));
    Get.lazyPut(() => LoginUsernameDataSourceImpl(
      Get.find<RecentLoginUsernameCacheClient>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => LogoutOidcInteractor(
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => DeleteAuthorityOidcInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>())
    );
    Get.lazyPut(() => GetStoredTokenOidcInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>(),
    ));
    Get.lazyPut(() => GetAuthenticatedAccountInteractor(
      Get.find<AccountRepository>(),
      Get.find<GetCredentialInteractor>(),
      Get.find<GetStoredTokenOidcInteractor>(),
    ));
    Get.lazyPut(() => AuthenticationInteractor(
        Get.find<AuthenticationRepository>(),
        Get.find<CredentialRepository>(),
        Get.find<AccountRepository>()
    ));
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
    Get.lazyPut(() => UpdateAuthenticationAccountInteractor(Get.find<AccountRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<AuthenticationRepository>(() => Get.find<AuthenticationRepositoryImpl>());
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
    Get.lazyPut<LoginUrlRepository>(() => Get.find<LoginUrlRepositoryImpl>());
    Get.lazyPut<LoginUsernameRepository>(() => Get.find<LoginUsernameRepositoryImpl>());

  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => AuthenticationRepositoryImpl(Get.find<AuthenticationDataSource>()));
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.lazyPut(() => LoginUrlRepositoryImpl(Get.find<LoginUrlDataSource>()));
    Get.lazyPut(() => LoginUsernameRepositoryImpl(Get.find<LoginUsernameDataSource>()));
  }
}
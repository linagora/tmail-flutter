import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/session/presentation/session_controller.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class SessionPageBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => SessionController(
      Get.find<LogoutOidcInteractor>(),
      Get.find<DeleteAuthorityOidcInteractor>(),
      Get.find<GetAuthenticatedAccountInteractor>(),
      Get.find<GetSessionInteractor>(),
      Get.find<DeleteCredentialInteractor>(),
      Get.find<CachingManager>(),
      Get.find<DeleteAuthorityOidcInteractor>(),
      Get.find<AuthorizationInterceptors>(),
      Get.find<AppToast>(),
      Get.find<DynamicUrlInterceptors>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
      Get.find<OIDCHttpClient>(),
      Get.find<AuthenticationClientBase>(),
      Get.find<TokenOidcCacheManager>(),
      Get.find<OidcConfigurationCacheManager>(),
      Get.find<RemoteExceptionThrower>(),
    ));
    Get.lazyPut(() => HiveAccountDatasourceImpl(
      Get.find<AccountCacheManager>(),
      Get.find<CacheExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => DeleteAuthorityOidcInteractor(
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<CredentialRepository>()));
    Get.lazyPut(() => LogoutOidcInteractor(
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => GetStoredTokenOidcInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>(),
    ));
    Get.lazyPut(() => GetAuthenticatedAccountInteractor(
      Get.find<AccountRepository>(),
      Get.find<GetCredentialInteractor>(),
      Get.find<GetStoredTokenOidcInteractor>(),
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
  }
}
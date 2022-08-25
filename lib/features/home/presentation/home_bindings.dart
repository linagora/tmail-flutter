import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource/cleanup_datasource.dart';
import 'package:tmail_ui_user/features/cleanup/data/datasource_impl/cleanup_datasource_impl.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_search_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/repository/cleanup_repository_impl.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_isolate_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => HomeController(
        Get.find<GetAuthenticatedAccountInteractor>(),
        Get.find<DynamicUrlInterceptors>(),
        Get.find<AuthorizationInterceptors>(),
        Get.find<AuthorizationIsolateInterceptors>(),
        Get.find<CleanupEmailCacheInteractor>(),
        Get.find<EmailReceiveManager>(),
        Get.find<CleanupRecentSearchCacheInteractor>(),
        Get.find<DeleteCredentialInteractor>(),
        Get.find<CachingManager>(),
        Get.find<DeleteAuthorityOidcInteractor>(),
        Get.find<CheckOIDCIsAvailableInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<CleanupDataSource>(() => Get.find<CleanupDataSourceImpl>());
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => CleanupDataSourceImpl(
        Get.find<EmailCacheManager>(),
        Get.find<RecentSearchCacheManager>(),
    ));
    Get.lazyPut(() => HiveAccountDatasourceImpl(
        Get.find<AccountCacheManager>()
    ));
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
        Get.find<OIDCHttpClient>(),
        Get.find<AuthenticationClientBase>(),
        Get.find<TokenOidcCacheManager>(),
        Get.find<OidcConfigurationCacheManager>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetStoredTokenOidcInteractor(
        Get.find<AuthenticationOIDCRepository>(),
        Get.find<CredentialRepository>()
    ));
    Get.lazyPut(() => GetAuthenticatedAccountInteractor(
        Get.find<AccountRepository>(),
        Get.find<GetCredentialInteractor>(),
        Get.find<GetStoredTokenOidcInteractor>()
    ));
    Get.lazyPut(() => CleanupEmailCacheInteractor(Get.find<CleanupRepository>()));
    Get.lazyPut(() => CleanupRecentSearchCacheInteractor(Get.find<CleanupRepository>()));
    Get.lazyPut(() => DeleteAuthorityOidcInteractor(Get.find<AuthenticationOIDCRepository>()));
    Get.lazyPut(() => CheckOIDCIsAvailableInteractor(Get.find<AuthenticationOIDCRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<CleanupRepository>(() => Get.find<CleanupRepositoryImpl>());
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => CleanupRepositoryImpl(Get.find<CleanupDataSource>()));
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
  }
}
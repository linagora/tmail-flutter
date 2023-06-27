import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class CredentialBindings extends BaseBindings {
  @override
  void bindingsInteractor() {
    Get.put(GetCredentialInteractor(Get.find<CredentialRepository>()));
    Get.put(DeleteCredentialInteractor(Get.find<CredentialRepository>()));
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
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => HiveAccountDatasourceImpl(
      Get.find<AccountCacheManager>(),
      Get.find<CacheExceptionThrower>())
    );
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
      Get.find<OIDCHttpClient>(),
      Get.find<AuthenticationClientBase>(),
      Get.find<TokenOidcCacheManager>(),
      Get.find<OidcConfigurationCacheManager>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
  }

  @override
  void bindingsRepository() {
    Get.put<CredentialRepository>(Get.find<CredentialRepositoryImpl>());
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(CredentialRepositoryImpl(
      Get.find<SharedPreferences>(),
      Get.find<AuthenticationInfoCacheManager>())
    );
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
  }

  @override
  void bindingsController() {
  }
}
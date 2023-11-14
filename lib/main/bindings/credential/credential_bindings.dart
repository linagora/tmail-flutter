import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_datasource_impl.dart';
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
import 'package:tmail_ui_user/features/login/data/repository/authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/credential_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class CredentialBindings extends InteractorsBindings {

  @override
  void bindingsInteractor() {
    Get.put(GetCredentialInteractor(Get.find<CredentialRepository>()));
    Get.put(DeleteCredentialInteractor(Get.find<CredentialRepository>()));
    Get.put(LogoutOidcInteractor(
      Get.find<AccountRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.put(DeleteAuthorityOidcInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>())
    );
    Get.put(GetStoredTokenOidcInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<CredentialRepository>(),
    ));
    Get.put(GetAuthenticatedAccountInteractor(
      Get.find<AccountRepository>(),
      Get.find<GetCredentialInteractor>(),
      Get.find<GetStoredTokenOidcInteractor>(),
    ));
    Get.put(AuthenticationInteractor(
      Get.find<AuthenticationRepository>(),
      Get.find<CredentialRepository>(),
      Get.find<AccountRepository>()
    ));
    Get.put(UpdateAuthenticationAccountInteractor(Get.find<AccountRepository>()));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.put(HiveAccountDatasourceImpl(
      Get.find<AccountCacheManager>(),
      Get.find<CacheExceptionThrower>())
    );
    Get.put(AuthenticationDataSourceImpl());
    Get.put(AuthenticationOIDCDataSourceImpl(
      Get.find<OIDCHttpClient>(),
      Get.find<AuthenticationClientBase>(),
      Get.find<TokenOidcCacheManager>(),
      Get.find<OidcConfigurationCacheManager>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.put<AccountDatasource>(Get.find<HiveAccountDatasourceImpl>());
    Get.put<AuthenticationDataSource>(Get.find<AuthenticationDataSourceImpl>());
    Get.put<AuthenticationOIDCDataSource>(Get.find<AuthenticationOIDCDataSourceImpl>());
  }

  @override
  void bindingsRepository() {
    Get.put<CredentialRepository>(Get.find<CredentialRepositoryImpl>());
    Get.put<AccountRepository>(Get.find<AccountRepositoryImpl>());
    Get.put<AuthenticationRepository>(Get.find<AuthenticationRepositoryImpl>());
    Get.put<AuthenticationOIDCRepository>(Get.find<AuthenticationOIDCRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(CredentialRepositoryImpl(
      Get.find<SharedPreferences>(),
      Get.find<AuthenticationInfoCacheManager>()
    ));
    Get.put(AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.put(AuthenticationRepositoryImpl(Get.find<AuthenticationDataSource>()));
    Get.put(AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
  }
}
import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
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
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';

class LoginBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => LoginController(
        Get.find<AuthenticationInteractor>(),
        Get.find<DynamicUrlInterceptors>(),
        Get.find<AuthorizationInterceptors>(),
        Get.find<CheckOIDCIsAvailableInteractor>(),
        Get.find<GetOIDCConfigurationInteractor>(),
        Get.find<GetTokenOIDCInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AuthenticationDataSource>(() => Get.find<AuthenticationDataSourceImpl>());
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AuthenticationDataSourceImpl());
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
        Get.find<OIDCHttpClient>(),
        Get.find<TokenOidcCacheManager>()
    ));
    Get.lazyPut(() => HiveAccountDatasourceImpl(
        Get.find<AccountCacheManager>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => AuthenticationInteractor(
        Get.find<AuthenticationRepository>(),
        Get.find<CredentialRepository>(),
        Get.find<AccountRepository>()
    ));
    Get.lazyPut(() => CheckOIDCIsAvailableInteractor(
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
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<CredentialRepository>(() => Get.find<CredentialRepositoryImpl>());
    Get.lazyPut<AuthenticationRepository>(() => Get.find<AuthenticationRepositoryImpl>());
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => CredentialRepositoryImpl(Get.find<SharedPreferences>()));
    Get.lazyPut(() => AuthenticationRepositoryImpl(Get.find<AuthenticationDataSource>()));
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
  }
}
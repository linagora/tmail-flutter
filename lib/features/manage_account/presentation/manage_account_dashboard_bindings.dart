import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_bindings.dart';

class ManageAccountDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    ManageAccountMenuBindings().dependencies();
    ProfileBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => ManageAccountDashBoardController(
        Get.find<LogoutOidcInteractor>(),
        Get.find<DeleteAuthorityOidcInteractor>()
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AccountDatasource>(() => Get.find<HiveAccountDatasourceImpl>());
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => HiveAccountDatasourceImpl(Get.find<AccountCacheManager>()));
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
        Get.find<OIDCHttpClient>(),
        Get.find<TokenOidcCacheManager>(),
        Get.find<OidcConfigurationCacheManager>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetUserProfileInteractor(Get.find<CredentialRepository>()));
    Get.lazyPut(() => LogoutOidcInteractor(
        Get.find<AccountRepository>(),
        Get.find<AuthenticationOIDCRepository>(),
    ));
    Get.lazyPut(() => DeleteAuthorityOidcInteractor(Get.find<AuthenticationOIDCRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<AccountRepository>(() => Get.find<AccountRepositoryImpl>());
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
  }
}
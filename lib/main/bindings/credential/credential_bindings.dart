import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/login/data/datasource/account_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/account_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_basic_auth_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class CredentialBindings extends InteractorsBindings {

  @override
  void bindingsInteractor() {
    Get.put(LogoutCurrentAccountBasicAuthInteractor(Get.find<AccountRepository>()));
    Get.put(LogoutCurrentAccountOidcInteractor(
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<AccountRepository>()));
    Get.put(LogoutCurrentAccountInteractor(
      Get.find<AccountRepository>(),
      Get.find<LogoutCurrentAccountBasicAuthInteractor>(),
      Get.find<LogoutCurrentAccountOidcInteractor>(),
    ));
    Get.put(GetCurrentAccountCacheInteractor(Get.find<AccountRepository>()));
    Get.put(AuthenticationInteractor(
      Get.find<AuthenticationRepository>(),
      Get.find<AccountRepository>()
    ));
    Get.put(UpdateCurrentAccountCacheInteractor(Get.find<AccountRepository>()));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.put(HiveAccountDatasourceImpl(
      Get.find<AccountCacheManager>(),
      Get.find<IOSSharingManager>(),
      Get.find<CacheExceptionThrower>())
    );
    Get.put(AuthenticationDataSourceImpl(Get.find<RemoteExceptionThrower>()));
    Get.put(AuthenticationOIDCDataSourceImpl(
      Get.find<OIDCHttpClient>(),
      Get.find<AuthenticationClientBase>(),
      Get.find<RemoteExceptionThrower>(),
      Get.find<CacheExceptionThrower>(),
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
    Get.put<AccountRepository>(Get.find<AccountRepositoryImpl>());
    Get.put<AuthenticationRepository>(Get.find<AuthenticationRepositoryImpl>());
    Get.put<AuthenticationOIDCRepository>(Get.find<AuthenticationOIDCRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.put(AccountRepositoryImpl(Get.find<AccountDatasource>()));
    Get.put(AuthenticationRepositoryImpl(Get.find<AuthenticationDataSource>()));
    Get.put(AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
  }
}
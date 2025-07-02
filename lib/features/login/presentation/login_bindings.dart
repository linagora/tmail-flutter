import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_username_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/hive_login_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/login_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_service.dart';
import 'package:tmail_ui_user/features/login/data/repository/login_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/dns_lookup_to_get_jmap_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/remove_auth_destination_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/try_guessing_web_finger_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/starting_page/data/datasource/saas_authentication_datasource.dart';
import 'package:tmail_ui_user/features/starting_page/data/datasource_impl/saas_authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/starting_page/data/repository/saas_authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/starting_page/domain/repository/saas_authentication_repository.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class LoginBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.create(() => LoginController(
      Get.find<AuthenticationInteractor>(),
      Get.find<CheckOIDCIsAvailableInteractor>(),
      Get.find<GetOIDCConfigurationInteractor>(),
      Get.find<GetTokenOIDCInteractor>(),
      Get.find<AuthenticateOidcOnBrowserInteractor>(),
      Get.find<GetAuthenticationInfoInteractor>(),
      Get.find<GetStoredOidcConfigurationInteractor>(),
      Get.find<SaveLoginUrlOnMobileInteractor>(),
      Get.find<GetAllRecentLoginUrlOnMobileInteractor>(),
      Get.find<SaveLoginUsernameOnMobileInteractor>(),
      Get.find<GetAllRecentLoginUsernameOnMobileInteractor>(),
      Get.find<DNSLookupToGetJmapUrlInteractor>(),
      Get.find<SignInTwakeWorkplaceInteractor>(),
      Get.find<TryGuessingWebFingerInteractor>(),
      Get.find<RemoveAuthDestinationUrlInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<LoginDataSource>(() => Get.find<LoginDataSourceImpl>());
    Get.lazyPut<SaasAuthenticationDataSource>(
      () => Get.find<SaasAuthenticationDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => HiveLoginDataSourceImpl(
      Get.find<RecentLoginUrlCacheManager>(),
      Get.find<RecentLoginUsernameCacheManager>(),
      Get.find<CacheExceptionThrower>()
    ));
    Get.lazyPut(() => LoginDataSourceImpl(
      Get.find<DNSService>(),
      Get.find<RemoteExceptionThrower>(),
    ));
    Get.lazyPut(() => SaasAuthenticationDataSourceImpl(
      Get.find<AuthenticationClientBase>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => SaveLoginUrlOnMobileInteractor(Get.find<LoginRepository>(),));
    Get.lazyPut(() => GetAllRecentLoginUrlOnMobileInteractor(Get.find<LoginRepository>()));
    Get.lazyPut(() => SaveLoginUsernameOnMobileInteractor(Get.find<LoginRepository>(),));
    Get.lazyPut(() => GetAllRecentLoginUsernameOnMobileInteractor(Get.find<LoginRepository>()));
    Get.lazyPut(() => DNSLookupToGetJmapUrlInteractor(Get.find<LoginRepository>()));
    Get.lazyPut(() => SignInTwakeWorkplaceInteractor(
      Get.find<SaasAuthenticationRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<AccountRepository>(),
      Get.find<CredentialRepository>(),
    ));
    Get.lazyPut(() => TryGuessingWebFingerInteractor(
      Get.find<AuthenticationOIDCRepository>(),
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<LoginRepository>(() => Get.find<LoginRepositoryImpl>());
    Get.lazyPut<SaasAuthenticationRepository>(
      () => Get.find<SaasAuthenticationRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => LoginRepositoryImpl(
      {
        DataSourceType.hiveCache: Get.find<HiveLoginDataSourceImpl>(),
        DataSourceType.network: Get.find<LoginDataSource>(),
      }
    ));
    Get.lazyPut(() => SaasAuthenticationRepositoryImpl(
      Get.find<SaasAuthenticationDataSource>()));
  }
}
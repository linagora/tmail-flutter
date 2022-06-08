import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/datasource/authentication_oidc_datasource.dart';
import 'package:tmail_ui_user/features/login/data/datasource_impl/authentication_oidc_datasource_impl.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/login/data/repository/authentication_oidc_repository_impl.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/session/presentation/session_controller.dart';

class SessionPageBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => SessionController(
      Get.find<GetSessionInteractor>(),
      Get.find<DeleteCredentialInteractor>(),
      Get.find<CachingManager>(),
      Get.find<DeleteAuthorityOidcInteractor>(),
      Get.find<AuthorizationInterceptors>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<AuthenticationOIDCDataSource>(() => Get.find<AuthenticationOIDCDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => AuthenticationOIDCDataSourceImpl(
        Get.find<OIDCHttpClient>(),
        Get.find<AuthenticationClientBase>(),
        Get.find<TokenOidcCacheManager>(),
        Get.find<OidcConfigurationCacheManager>()
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => DeleteAuthorityOidcInteractor(Get.find<AuthenticationOIDCRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<AuthenticationOIDCRepository>(() => Get.find<AuthenticationOIDCRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => AuthenticationOIDCRepositoryImpl(Get.find<AuthenticationOIDCDataSource>()));
  }
}
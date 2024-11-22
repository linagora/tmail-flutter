import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/starting_page/data/datasource/saas_authentication_datasource.dart';
import 'package:tmail_ui_user/features/starting_page/data/datasource_impl/saas_authentication_datasource_impl.dart';
import 'package:tmail_ui_user/features/starting_page/data/repository/saas_authentication_repository_impl.dart';
import 'package:tmail_ui_user/features/starting_page/domain/repository/saas_authentication_repository.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_up_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class TwakeWelcomeBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => TwakeWelcomeController(
      Get.find<SignInTwakeWorkplaceInteractor>(),
      Get.find<SignUpTwakeWorkplaceInteractor>(),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => SignInTwakeWorkplaceInteractor(
      Get.find<SaasAuthenticationRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<AccountRepository>(),
      Get.find<CredentialRepository>(),
    ));
    Get.lazyPut(() => SignUpTwakeWorkplaceInteractor(
      Get.find<SaasAuthenticationRepository>(),
      Get.find<AuthenticationOIDCRepository>(),
      Get.find<AccountRepository>(),
      Get.find<CredentialRepository>(),
    ));
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => SaasAuthenticationDataSourceImpl(
      Get.find<AuthenticationClientBase>(),
      Get.find<RemoteExceptionThrower>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<SaasAuthenticationDataSource>(
      () => Get.find<SaasAuthenticationDataSourceImpl>());
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<SaasAuthenticationRepository>(
      () => Get.find<SaasAuthenticationRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => SaasAuthenticationRepositoryImpl(
      Get.find<SaasAuthenticationDataSource>(),
    ));
  }
}
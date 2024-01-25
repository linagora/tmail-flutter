import 'package:core/utils/crypto/crypto_utils.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:saas/data/repository/saas_authentication_repository_impl.dart';
import 'package:saas/domain/usecase/sign_in_saas_interactor.dart';
import 'package:saas/domain/usecase/sign_up_saas_interactor.dart';
import 'package:saas/domain/utils/code_challenge_generator.dart';
import 'package:saas/domain/utils/code_verifier_generator.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_id/twake_id_controller.dart';
import 'package:saas/data/datasource/oauth_datasource.dart';
import 'package:saas/data/datasource_impl/oauth_datasource_impl.dart';
import 'package:saas/domain/repository/saas_authentication_repository.dart';

class TwakeIdBindings extends BaseBindings {

  @override
  void dependencies() {
    _bindingsCodeVerifier();
    super.dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => TwakeIdController(
      Get.find<SignInSaasInteractor>(),
      Get.find<SignUpSaasInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<OAuthDataSource>(() => Get.find<OAuthDataSource>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut<OAuthDataSourceImp>(() => OAuthDataSourceImp(
      Dio(Get.find<BaseOptions>()),
    ));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut<SignInSaasInteractor>(() => SignInSaasInteractor(
      Get.find<SaasAuthenticationRepository>(),
    ));
    Get.lazyPut<SignUpSaasInteractor>(() => SignUpSaasInteractor(
      Get.find<SaasAuthenticationRepository>(),
    ));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<SaasAuthenticationRepository>(() => Get.find<SaasAuthenticationRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut<SaasAuthenticationRepositoryImpl>(() => SaasAuthenticationRepositoryImpl(
      Get.find<CodeVerifierGenerator>(),
      Get.find<CodeChallengeGenerator>(),
      Get.find<OAuthDataSourceImp>(),
    ));
  }

  void _bindingsCodeVerifier() {
    Get.lazyPut(() => CryptoUtils());
    Get.lazyPut(() => CodeChallengeGenerator(
      Get.find<CryptoUtils>(),
    ));
    Get.lazyPut(() => CodeVerifierGenerator(
      Get.find<CryptoUtils>()
    ));
  }
}
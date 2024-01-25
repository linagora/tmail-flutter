
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:saas/data/datasource_impl/oauth_datasource_impl.dart';
import 'package:saas/data/repository/saas_authentication_repository_impl.dart';
import 'package:saas/domain/utils/code_challenge_generator.dart';
import 'package:saas/domain/utils/code_verifier_generator.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class TwakeIdController extends GetxController {

  final dioDMM = Dio()..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  @override
  void onInit() {
    ThemeUtils.setPreferredPortraitOrientations();
    super.onInit();
  }

  Future<void> createSaasAccount() async {
    final saasRepository = SaasAuthenticationRepositoryImpl(
        CodeVerifierGenerator(CryptoUtils()),
        CodeChallengeGenerator(CryptoUtils()),
        OAuthDataSourceImp(dioDMM));
    print('hello');
    final signUpUrl = Uri.parse('https://register.tom-dev.xyz/');
    final redirectParams = 'twake.mail://oauthredirect';
    final clientId = 'twakemail-mobile';
    await saasRepository.signUp(signUpUrl, clientId, redirectParams);
  }

  Future<void> signInToSaas() async {
    final saasRepository = SaasAuthenticationRepositoryImpl(
        CodeVerifierGenerator(CryptoUtils()),
        CodeChallengeGenerator(CryptoUtils()),
        OAuthDataSourceImp(dioDMM));
    final signInUrl = Uri.parse('https://register.tom-dev.xyz/');
    final redirectParams = 'twake.mail://oauthredirect';
    final clientId = 'twakemail-mobile';
    await saasRepository.signIn(signInUrl, clientId, redirectParams);
  }

  void handleUseCompanyServer() {
    popAndPush(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.dnsLookupForm));
  }

  // Uri _genPostRedirectedParams(Uri registerUrl) {
  //   if (!registerUrl.isScheme('https')) {
  //     throw Exception('Login url must be https');
  //   }
  //   final fullRegisterUrl = '$registerUrl?client_id=$_saasClientId&$_postRegisteredRedirectUrlPath=$_saasRedirectScheme://oauthredirect';
  //   return fullRegisterUrl;
  // }
  //
  // String _genPostRedirectedParams(Uri loginUrl, String codeChallenge) {
  //   if (!loginUrl.isScheme('https')) {
  //     throw Exception('Login url must be https');
  //   }
  //   final fullLoginUrl = '$loginUrl?client_id=$_saasClientId&$_postLoginRedirectUrlPath=$_saasRedirectScheme://oauthredirect&challenge_code=$codeChallenge';
  //   return fullLoginUrl;
  // }
}
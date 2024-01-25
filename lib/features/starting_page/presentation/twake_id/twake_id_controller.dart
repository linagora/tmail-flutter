import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:saas/domain/usecase/sign_in_saas_interactor.dart';
import 'package:saas/domain/usecase/sign_up_saas_interactor.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class TwakeIdController extends GetxController {
  final SignInSaasInteractor _signInSaasInteractor;
  final SignUpSaasInteractor _signUpSaasInteractor;

  TwakeIdController(this._signInSaasInteractor, this._signUpSaasInteractor);


  Future<void> signInToSaas() async {
    final oidcClientId = AppConfig.oidcClientId;
    if (oidcClientId == null) {}
    _signInSaasInteractor.execute(
      registrationSiteUrl: Uri.parse(AppConfig.registrationUrl),
      clientId: oidcClientId!,
      redirectQueryParameter: 'twake.mail://oauthredirect',
    ).listen((state) {
      log('TwakeIdController::signInToSaas(): event: $state');
    });
  }

  Future<void> createSaasAccount() async {
    final oidcClientId = AppConfig.oidcClientId;
    if (oidcClientId == null) {}
    _signUpSaasInteractor.execute(
      registrationSiteUrl: Uri.parse(AppConfig.registrationUrl),
      clientId: oidcClientId!,
      redirectQueryParameter: 'twake.mail://oauthredirect',
    ).listen((event) {
      log('TwakeIdController::createSaasAccount(): event: $event');
    });
  }
}

import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/model/base_url_oidc_response.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension HandleWebFingerToGetTokenExtension on HomeController {
  bool isNotSignInOnWeb(Failure failure) =>
      PlatformInfo.isWeb && isNotSignedIn(failure);

  void checkOIDCIsAvailable() {
    final baseUri = Uri.tryParse(AppConfig.baseUrl);

    if (baseUri == null) {
      goToLogin();
    } else {
      consumeState(
        checkOIDCIsAvailableInteractor.execute(OIDCRequest.fromUri(baseUri)),
      );
    }
  }

  void getOIDCConfiguration(OIDCResponse oidcResponse) {
    consumeState(getOIDCConfigurationInteractor.execute(oidcResponse));
  }

  void handleOIDCConfigurationSuccess(OIDCConfiguration oidcConfig) {
    performUserAuthenticationOnWeb(oidcConfig);
  }

  void performUserAuthenticationOnWeb(OIDCConfiguration oidcConfig) {
    _removeAuthDestinationUrl();

    consumeState(authenticateOidcOnBrowserInteractor.execute(oidcConfig));
  }

  void _removeAuthDestinationUrl() {
    consumeState(removeAuthDestinationUrlInteractor.execute());
  }

  void handleCheckOIDCIsAvailableFailure() {
    final baseUri = Uri.tryParse(AppConfig.baseUrl);

    if (baseUri == null) {
      consumeState(
        Stream.value(Left(GetOIDCConfigurationFailure(CanNotFoundBaseUrl()))),
      );
    } else {
      tryGetOIDCConfigurationFromBaseUri(baseUri);
    }
  }

  void tryGetOIDCConfigurationFromBaseUri(Uri baseUri) {
    getOIDCConfiguration(BaseUrlOidcResponse(baseUri));
  }

  bool isGetTokenOIDCFailure(Failure? failure) {
    return failure is GetOIDCConfigurationFailure ||
        failure is GetOIDCConfigurationFromBaseUrlFailure ||
        failure is GetTokenOIDCFailure;
  }
}

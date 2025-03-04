
import 'package:tmail_ui_user/features/login/domain/model/base_url_oidc_response.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';

extension HandleOpenidConfiguration on LoginController {

  void tryGetOIDCConfigurationFromBaseUrl(Uri baseUri) {
    getOIDCConfiguration(BaseUrlOidcResponse(baseUri));
  }

  void handleGetOIDCConfigurationFromBaseUrlFailure() {
    handleOIDCIsNotAvailable(featureFailure);
  }
}
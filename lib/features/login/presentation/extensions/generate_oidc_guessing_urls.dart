import 'package:model/oidc/request/oidc_request.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/login/domain/model/oidc_guessing_origin.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';

extension GenerateOidcGuessingUrls on LoginController {
  List<OIDCRequest> generateOidcGuessingUrls(String email) {
    if (!EmailUtils.isEmailAddressValid(email)) {
      return [];
    }

    return OidcGuessingOrigin.values.map(
      (guessingOrigin) => OIDCRequest(
        baseUrl: guessingOrigin.url(email),
        resourceUrl: guessingOrigin.url(email)
      )
    ).toList();
  }
}
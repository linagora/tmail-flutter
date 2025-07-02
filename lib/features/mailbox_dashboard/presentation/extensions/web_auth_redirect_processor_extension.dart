import 'package:core/presentation/state/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension WebAuthRedirectProcessorExtension on MailboxDashBoardController {
  void getAuthenticationInfoRedirect() {
    consumeState(getAuthenticationInfoInteractor.execute());
  }

  void getStoredOidcConfiguration() {
    consumeState(getStoredOidcConfigurationInteractor.execute());
  }

  void getTokenOIDCAction(OIDCConfiguration oidcConfig) {
    final baseUri = Uri.tryParse(AppConfig.baseUrl);

    if (baseUri == null) {
      consumeState(
        Stream.value(Left(GetTokenOIDCFailure(CanNotFoundBaseUrl()))),
      );
    } else {
      consumeState(getTokenOIDCInteractor.execute(baseUri, oidcConfig));
    }
  }

  bool isGetTokenOIDCFailure(Failure? failure) {
    return failure is GetStoredOidcConfigurationFailure ||
        failure is GetTokenOIDCFailure;
  }

  void tryGetAuthenticatedAccountToUseApp() {
    getAuthenticatedAccountAction();
  }

  void backToHomeScreen() {
    pushAndPopAll(AppRoutes.home);
  }
}

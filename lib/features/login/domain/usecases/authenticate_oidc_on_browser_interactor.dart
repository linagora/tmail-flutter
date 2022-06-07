
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';

class AuthenticateOidcOnBrowserInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;

  AuthenticateOidcOnBrowserInteractor(this.authenticationOIDCRepository);

  Future<Either<Failure, Success>> execute(Uri baseUrl, OIDCConfiguration config) async {
    try {
      await authenticationOIDCRepository.authenticateOidcOnBrowser(
          config.clientId,
          config.redirectUrl,
          config.discoveryUrl,
          config.scopes);
      return Right<Failure, Success>(AuthenticateOidcOnBrowserSuccess());
    } catch (e) {
      logError('AuthenticateOidcOnBrowserInteractor::execute(): $e');
      return Left<Failure, Success>(AuthenticateOidcOnBrowserFailure(e));
    }
  }
}
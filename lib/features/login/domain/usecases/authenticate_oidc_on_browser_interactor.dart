
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';

class AuthenticateOidcOnBrowserInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;

  AuthenticateOidcOnBrowserInteractor(this.authenticationOIDCRepository);

  Stream<Either<Failure, Success>> execute(String baseUrl, OIDCConfiguration oidcConfiguration) async* {
    try {
      yield Right<Failure, Success>(AuthenticateOidcOnBrowserLoading());
      await authenticationOIDCRepository.authenticateOidcOnBrowser(oidcConfiguration);
      yield Right<Failure, Success>(AuthenticateOidcOnBrowserSuccess(baseUrl, oidcConfiguration));
    } catch (e) {
      yield Left<Failure, Success>(AuthenticateOidcOnBrowserFailure(e));
    }
  }
}
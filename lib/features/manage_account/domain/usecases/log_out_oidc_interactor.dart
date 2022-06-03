
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/log_out_oidc_state.dart';

class LogoutOidcInteractor {

  final AccountRepository _accountRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;

  LogoutOidcInteractor(this._accountRepository, this._authenticationOIDCRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      final currentAccount = await _accountRepository.getCurrentAccount();

      if (currentAccount.authenticationType == AuthenticationType.oidc) {
        final result = await Future.wait([
          _authenticationOIDCRepository.getStoredTokenOIDC(currentAccount.id),
          _authenticationOIDCRepository.getStoredOidcConfiguration()
        ]).then((result) async {
          final tokenOidc = result.first as TokenOIDC;
          final oidcConfig = result.last as OIDCConfiguration;
          return await _authenticationOIDCRepository.logout(tokenOidc.tokenId, oidcConfig);
        });
        log('LogoutOidcInteractor::execute(): statusSuccess: $result');
        if (result) {
          yield Right<Failure, Success>(LogoutOidcSuccess());
        } else {
          yield Left<Failure, Success>(LogoutOidcFailure(null));
        }
      } else {
        yield Left<Failure, Success>(LogoutOidcFailure(NotFoundAuthenticatedAccountException()));
      }
    } catch (e) {
      log('LogoutOidcInteractor::execute(): EXCEPTION: $e');
      yield Left<Failure, Success>(LogoutOidcFailure(e));
    }
  }
}
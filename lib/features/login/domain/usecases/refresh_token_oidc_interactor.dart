
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/refresh_token_oidc_state.dart';

class RefreshTokenOIDCInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;
  final AccountRepository _accountRepository;

  RefreshTokenOIDCInteractor(this.authenticationOIDCRepository, this._accountRepository);

  Future<Either<Failure, Success>> execute(
      OIDCConfiguration config,
      String refreshToken) async {
    try {
      final newTokenOIDC = await authenticationOIDCRepository.refreshingTokensOIDC(
          config.clientId,
          config.redirectUrl,
          config.discoveryUrl,
          config.scopes,
          refreshToken);

      await Future.wait([
        _accountRepository.setCurrentAccount(Account(
            newTokenOIDC.tokenId.hashCode.toString(),
            AuthenticationType.oidc,
            isSelected: true)),
        authenticationOIDCRepository.persistTokenOIDC(newTokenOIDC),
      ]);
      return Right<Failure, Success>(RefreshTokenOIDCSuccess(newTokenOIDC));
    } catch (e) {
      logError('RefreshTokenOIDCInteractor::execute(): $e');
      return Left<Failure, Success>(RefreshTokenOIDCFailure(e));
    }
  }
}
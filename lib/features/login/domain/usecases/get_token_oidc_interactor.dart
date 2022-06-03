
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';

class GetTokenOIDCInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;
  final AccountRepository _accountRepository;
  final CredentialRepository _credentialRepository;

  GetTokenOIDCInteractor(this._credentialRepository, this.authenticationOIDCRepository, this._accountRepository);

  Future<Either<Failure, Success>> execute(Uri baseUrl, OIDCConfiguration config) async {
    try {
      log('GetTokenOIDCInteractor::execute(): baseUrl: $baseUrl');
      final tokenOIDC = await authenticationOIDCRepository
        .getTokenOIDC(config.clientId, config.redirectUrl, config.discoveryUrl, config.scopes);
      await Future.wait([
        _credentialRepository.saveBaseUrl(baseUrl),
        _accountRepository.setCurrentAccount(Account(
            tokenOIDC.tokenIdHash,
            AuthenticationType.oidc,
            isSelected: true)),
        authenticationOIDCRepository.persistTokenOIDC(tokenOIDC),
        authenticationOIDCRepository.persistAuthorityOidc(config.authority),
      ]);
      return Right<Failure, Success>(GetTokenOIDCSuccess(tokenOIDC));
    } catch (e) {
      logError('GetTokenOIDCInteractor::execute(): $e');
      return Left<Failure, Success>(GetTokenOIDCFailure(e));
    }
  }
}
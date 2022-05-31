
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';

class GetTokenOIDCInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;
  final AccountRepository _accountRepository;
  final CredentialRepository _credentialRepository;

  GetTokenOIDCInteractor(this._credentialRepository, this.authenticationOIDCRepository, this._accountRepository);

  Future<Either<Failure, Success>> execute(
      Uri baseUrl,
      String clientId,
      String redirectUrl,
      String discoveryUrl,
      List<String> scopes
  ) async {
    try {
      log('GetTokenOIDCInteractor::execute(): baseUrl: $baseUrl');
      final tokenOIDC = await authenticationOIDCRepository
        .getTokenOIDC(clientId, redirectUrl, discoveryUrl, scopes);
      await Future.wait([
        _credentialRepository.saveBaseUrl(baseUrl),
        _accountRepository.setCurrentAccount(Account(
            tokenOIDC.tokenId.hashCode.toString(),
            AuthenticationType.oidc,
            isSelected: true)),
        authenticationOIDCRepository.persistTokenOIDC(tokenOIDC)
      ]);
      return Right<Failure, Success>(GetTokenOIDCSuccess(tokenOIDC));
    } catch (e) {
      logError('GetTokenOIDCInteractor::execute(): $e');
      return Left<Failure, Success>(GetTokenOIDCFailure(e));
    }
  }
}
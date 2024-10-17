import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:rich_text_composer/views/commons/logger.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/starting_page/domain/repository/saas_authentication_repository.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_saas_state.dart';

class SignInSaasInteractor {
  final SaasAuthenticationRepository _saasRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AccountRepository _accountRepository;
  final CredentialRepository _credentialRepository;

  SignInSaasInteractor(
    this._saasRepository,
    this._authenticationOIDCRepository,
    this._accountRepository,
    this._credentialRepository
  );

  Stream<Either<Failure, Success>> execute({
    required Uri baseUri,
    required OIDCConfiguration oidcConfiguration
  }) async* {
    try {
      yield Right<Failure, Success>(SignInSaasLoading());

      final tokenOIDC = await _saasRepository.signIn(oidcConfiguration);

      await Future.wait([
        _credentialRepository.saveBaseUrl(baseUri),
        _authenticationOIDCRepository.persistTokenOIDC(tokenOIDC),
        _authenticationOIDCRepository.persistAuthorityOidc(oidcConfiguration.authority),
      ]);

      await _accountRepository.setCurrentAccount(
        PersonalAccount(
          tokenOIDC.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true
        )
      );

      yield Right<Failure, Success>(SignInSaasSuccess(tokenOIDC, baseUri, oidcConfiguration));
    } catch (e) {
      logError('SignInSaasInteractor::execute():Exception = $e');
      yield Left<Failure, Success>(SignInSaasFailure(e));
    }
  }
}
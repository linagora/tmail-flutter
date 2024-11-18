import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class AutoSignInViaDeepLinkInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AccountRepository _accountRepository;
  final CredentialRepository _credentialRepository;

  const AutoSignInViaDeepLinkInteractor(
    this._authenticationOIDCRepository,
    this._accountRepository,
    this._credentialRepository
  );

  Stream<Either<Failure, Success>> execute({
    required Uri baseUri,
    required TokenOIDC tokenOIDC,
    required OIDCConfiguration oidcConfiguration
  }) async* {
    try {
      yield Right<Failure, Success>(AutoSignInViaDeepLinkLoading());

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

      yield Right<Failure, Success>(AutoSignInViaDeepLinkSuccess(
        tokenOIDC,
        baseUri,
        oidcConfiguration,
      ));
    } catch (e) {
      yield Left<Failure, Success>(AutoSignInViaDeepLinkFailure(e));
    }
  }
}
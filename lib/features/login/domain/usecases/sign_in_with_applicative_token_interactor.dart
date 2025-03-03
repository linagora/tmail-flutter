import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/sign_in_with_applicative_token_state.dart';
import 'package:uuid/uuid.dart';

class SignInWithApplicativeTokenInteractor {
  final CredentialRepository _credentialRepository;
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AccountRepository _accountRepository;

  const SignInWithApplicativeTokenInteractor(
    this._credentialRepository,
    this._authenticationOIDCRepository,
    this._accountRepository,
  );

  Stream<Either<Failure, Success>> execute({
    required String applicativeToken,
    required Uri baseUri,
    required Uuid uuid,
  }) async* {
    try {
      yield Right(SigningInWithApplicativeToken());
      final tokenOIDC = TokenOIDC(applicativeToken, TokenId(uuid.v4()), '');
      final oidcConfiguration = OIDCConfiguration(
        clientId: '',
        scopes: [],
        authority: '',
      );
      await Future.wait([
        _credentialRepository.saveBaseUrl(baseUri),
        _authenticationOIDCRepository.persistTokenOIDC(tokenOIDC),
        _authenticationOIDCRepository.persistOidcConfiguration(oidcConfiguration),
      ]);

      await _accountRepository.setCurrentAccount(
        PersonalAccount(
          tokenOIDC.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true
        )
      );

      yield Right(SignInWithApplicativeTokenSuccess(
        tokenOIDC,
        baseUri,
        oidcConfiguration,
      ));
    } catch (e) {
      logError('SignInWithApplicativeTokenInteractor::execute: $e');
      yield Left(SignInWithApplicativeTokenFailure(exception: e));
    }
  }
}
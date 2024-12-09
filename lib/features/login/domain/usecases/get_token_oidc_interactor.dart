
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';

class GetTokenOIDCInteractor {

  final AuthenticationOIDCRepository authenticationOIDCRepository;
  final AccountRepository _accountRepository;
  final CredentialRepository _credentialRepository;

  GetTokenOIDCInteractor(this._credentialRepository, this.authenticationOIDCRepository, this._accountRepository);

  Stream<Either<Failure, Success>> execute(Uri baseUrl, OIDCConfiguration config) async* {
    try {
      yield Right<Failure, Success>(GetTokenOIDCLoading());
      final tokenOIDC = await authenticationOIDCRepository.getTokenOIDC(
          config.clientId,
          config.redirectUrl,
          config.discoveryUrl,
          config.scopes);

      await Future.wait([
        _credentialRepository.saveBaseUrl(baseUrl),
        authenticationOIDCRepository.persistTokenOIDC(tokenOIDC),
        authenticationOIDCRepository.persistOidcConfiguration(config),
      ]);

      await _accountRepository.setCurrentAccount(
        PersonalAccount(
          tokenOIDC.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true
        )
      );
      yield Right<Failure, Success>(GetTokenOIDCSuccess(tokenOIDC, config));
    } on PlatformException catch (e) {
      logError('GetTokenOIDCInteractor::execute(): PlatformException ${e.message} - ${e.stacktrace}');
      if (NoSuitableBrowserForOIDCException.verifyException(e)) {
        yield Left<Failure, Success>(GetTokenOIDCFailure(NoSuitableBrowserForOIDCException()));
      } else {
        yield Left<Failure, Success>(GetTokenOIDCFailure(e));
      }
    } catch (e) {
      logError('GetTokenOIDCInteractor::execute(): $e');
      yield Left<Failure, Success>(GetTokenOIDCFailure(e));
    }
  }
}
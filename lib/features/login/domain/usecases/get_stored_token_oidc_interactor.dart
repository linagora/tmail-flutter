import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/uri_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';

class GetStoredTokenOidcInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final CredentialRepository _credentialRepository;

  GetStoredTokenOidcInteractor(this._authenticationOIDCRepository, this._credentialRepository);

  Stream<Either<Failure, Success>> execute({
    required PersonalAccount personalAccount,
    StateChange? stateChange
  }) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final futureValue = await Future.wait([
        _credentialRepository.getBaseUrl(),
        _authenticationOIDCRepository.getStoredTokenOIDC(personalAccount.id),
        _authenticationOIDCRepository.getStoredOidcConfiguration(),
      ], eagerError: true);

      final baseUrl = futureValue[0] as Uri;
      final tokenOidc = futureValue[1] as TokenOIDC;
      final oidcConfiguration = futureValue[2] as OIDCConfiguration;
      log('GetStoredTokenOidcInteractor::execute(): $tokenOidc');
      log('GetStoredTokenOidcInteractor::execute(): oidcConfiguration: $oidcConfiguration');

      if (_isCredentialValid(baseUrl)) {
        yield Right(GetStoredTokenOidcSuccess(
          baseUrl,
          tokenOidc,
          oidcConfiguration,
          personalAccount,
          stateChange: stateChange));
      } else {
        yield Left(GetStoredTokenOidcFailure(InvalidBaseUrl()));
      }
    } catch (e, stackTrace) {
      // Startup token read failed → the app silently routes to the login form.
      // Report to remote logging on MOBILE only: that is where a missing token
      // means a real "logged out overnight" regression.
      final message =
        'GetStoredTokenOidcInteractor::execute(): '
        'startup_token_unavailable=true | reason=${_classifyStartupFailure(e)} | '
        'accountId=${personalAccount.id} | error=$e';
      if (PlatformInfo.isMobile) {
        logError(
          message,
          exception: e,
          stackTrace: stackTrace,
          extras: {
            'startup_token_unavailable': true,
            'reason': _classifyStartupFailure(e),
            'error_type': e.runtimeType.toString(),
          },
        );
      } else {
        logWarning(message);
      }
      yield Left(GetStoredTokenOidcFailure(e));
    }
  }

  bool _isCredentialValid(Uri baseUrl) => baseUrl.isBaseUrlValid();

  String _classifyStartupFailure(Object error) {
    if (error is NotFoundStoredTokenException) {
      return 'no_stored_token';
    }
    final typeName = error.runtimeType.toString();
    if (typeName.contains('Hive') || error.toString().contains('Hive')) {
      // e.g. HiveError: unknown typeId / corrupted box / wrong encryption key.
      return 'hive_read_or_decrypt_error';
    }
    return 'other';
  }
}

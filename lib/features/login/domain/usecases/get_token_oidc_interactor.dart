
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';

class GetTokenOIDCInteractor {

  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AccountRepository _accountRepository;

  GetTokenOIDCInteractor(this._authenticationOIDCRepository, this._accountRepository);

  Stream<Either<Failure, Success>> execute(String baseUrl, OIDCConfiguration oidcConfiguration) async* {
    try {
      yield Right<Failure, Success>(GetTokenOIDCLoading());

      final tokenOIDC = await _authenticationOIDCRepository.getTokenOIDC(oidcConfiguration);

      final newAccount = PersonalAccount(
        id: tokenOIDC.tokenIdHash,
        authType: AuthenticationType.oidc,
        isSelected: true,
        baseUrl: baseUrl,
        tokenOidc: tokenOIDC);

      await _accountRepository.setCurrentAccount(newAccount);

      yield Right<Failure, Success>(GetTokenOIDCSuccess(newAccount));
    } catch (e) {
      yield Left<Failure, Success>(GetTokenOIDCFailure(e));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/repository/authentication_oidc_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/logout_current_account_oidc_state.dart';

class LogoutCurrentAccountOidcInteractor {
  final AuthenticationOIDCRepository _authenticationOIDCRepository;
  final AccountRepository _accountRepository;

  LogoutCurrentAccountOidcInteractor(
    this._authenticationOIDCRepository,
    this._accountRepository
  );

  Stream<Either<Failure, Success>> execute(PersonalAccount currentAccount) async* {
    try {
      yield Right<Failure, Success>(LogoutCurrentAccountOidcLoading());

      final oidcDiscoveryResponse = await _authenticationOIDCRepository.discoverOIDC(currentAccount.tokenOidc!.oidcConfiguration);

      final result = await _authenticationOIDCRepository.logout(
        currentAccount.tokenOidc!.tokenId,
        currentAccount.tokenOidc!.oidcConfiguration,
        oidcDiscoveryResponse
      );

      await _accountRepository.deleteCurrentAccount(currentAccount.id);

      if (result) {
        yield Right<Failure, Success>(LogoutCurrentAccountOidcSuccess(currentAccount));
      } else {
        yield Left<Failure, Success>(LogoutCurrentAccountOidcFailure(deletedAccount: currentAccount));
      }
    } catch (e) {
      yield Left<Failure, Success>(LogoutCurrentAccountOidcFailure(
        exception: e,
        deletedAccount: currentAccount));
    }
  }
}

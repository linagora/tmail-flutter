import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_token_oidc_interactor.dart';

class GetAuthenticatedAccountInteractor {
  final AccountRepository _accountRepository;
  final GetCredentialInteractor _getCredentialInteractor;
  final GetStoredTokenOidcInteractor _getStoredTokenOidcInteractor;

  GetAuthenticatedAccountInteractor(
    this._accountRepository,
    this._getCredentialInteractor,
    this._getStoredTokenOidcInteractor
  );

  Stream<Either<Failure, Success>> execute({StateChange? stateChange}) async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final account = await _accountRepository.getCurrentAccount();
      yield Right(GetAuthenticatedAccountSuccess(account));
      if (account.authenticationType == AuthenticationType.oidc) {
        yield* _getStoredTokenOidcInteractor.execute(
          personalAccount: account,
          stateChange: stateChange);
      } else {
        yield await _getCredentialInteractor.execute(
          personalAccount: account,
          stateChange: stateChange);
      }
    } catch (e) {
      yield Left(GetAuthenticatedAccountFailure(e));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
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

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(LoadingState());
      final account = await _accountRepository.getCurrentAccount();
      yield Right(GetAuthenticatedAccountSuccess(account));
      if (account.authenticationType == AuthenticationType.oidc) {
        yield* _getStoredTokenOidcInteractor.execute(account.id);
      } else {
        yield await _getCredentialInteractor.execute();
      }
    } catch (e) {
      logError('GetAuthenticatedAccountInteractor::execute(): $e');
      if (e is NotFoundAuthenticatedAccountException) {
        yield Left(NoAuthenticatedAccountFailure());
      } else {
        yield Left(GetAuthenticatedAccountFailure(e));
      }
    }
  }
}
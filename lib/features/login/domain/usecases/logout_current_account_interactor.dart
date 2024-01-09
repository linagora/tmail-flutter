import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/logout_current_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_basic_auth_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_oidc_interactor.dart';

class LogoutCurrentAccountInteractor {
  final AccountRepository _accountRepository;
  final LogoutCurrentAccountBasicAuthInteractor _logoutBasicAuthInteractor;
  final LogoutCurrentAccountOidcInteractor _logoutOidcInteractor;

  LogoutCurrentAccountInteractor(
    this._accountRepository,
    this._logoutBasicAuthInteractor,
    this._logoutOidcInteractor,
  );

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(LogoutCurrentAccountLoading());

      final currentAccount = await _accountRepository.getCurrentAccount();

      switch (currentAccount.authType) {
        case AuthenticationType.oidc:
          yield* _logoutOidcInteractor.execute(currentAccount);
          break;
        case AuthenticationType.basic:
          yield* _logoutBasicAuthInteractor.execute(currentAccount);
          break;
        default:
          yield Left<Failure, Success>(LogoutCurrentAccountFailure(
            exception: AuthenticationTypeNotSupportedException(),
            deletedAccount: currentAccount));
          break;
      }
    } catch (e) {
      yield Left<Failure, Success>(LogoutCurrentAccountFailure(exception: e));
    }
  }
}
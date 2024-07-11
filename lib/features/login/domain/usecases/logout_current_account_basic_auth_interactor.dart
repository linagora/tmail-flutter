import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/logout_current_account_basic_auth_state.dart';

class LogoutCurrentAccountBasicAuthInteractor {
  final AccountRepository _accountRepository;

  LogoutCurrentAccountBasicAuthInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute(PersonalAccount personalAccount) async* {
    try {
      yield Right<Failure, Success>(LogoutCurrentAccountBasicAuthLoading());
      await _accountRepository.deleteCurrentAccount(personalAccount.id);
      yield Right<Failure, Success>(LogoutCurrentAccountBasicAuthSuccess(personalAccount));
    } catch (e) {
      yield Left<Failure, Success>(LogoutCurrentAccountBasicAuthFailure(
        exception: e,
        deletedAccount: personalAccount));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/set_current_account_active_state.dart';

class SetCurrentActiveAccountInteractor {
  final AccountRepository _accountRepository;

  SetCurrentActiveAccountInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute(PersonalAccount activeAccount) async* {
    try{
      yield Right(SetCurrentActiveAccountLoading());
      await _accountRepository.setCurrentActiveAccount(activeAccount);
      yield Right(SetCurrentActiveAccountSuccess());
    } catch(e) {
      yield Left(SetCurrentActiveAccountFailure(e));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';

class GetAuthenticatedAccountInteractor {
  final AccountRepository _accountRepository;

  GetAuthenticatedAccountInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetAuthenticatedAccountLoading());
      final account = await _accountRepository.getCurrentAccount();
      yield Right<Failure, Success>(GetAuthenticatedAccountSuccess(account));
    } catch (e) {
      yield Left<Failure, Success>(GetAuthenticatedAccountFailure(e));
    }
  }
}
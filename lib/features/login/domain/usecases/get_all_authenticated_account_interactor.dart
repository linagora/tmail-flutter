import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_authenticated_account_state.dart';

class GetAllAuthenticatedAccountInteractor {
  final AccountRepository _accountRepository;

  GetAllAuthenticatedAccountInteractor(this._accountRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      final listAccount = await _accountRepository.getAllAccount();
      return Right<Failure, Success>(GetAllAuthenticatedAccountSuccess(listAccount));
    } catch (e) {
      return Left<Failure, Success>(GetAllAuthenticatedAccountFailure(e));
    }
  }
}
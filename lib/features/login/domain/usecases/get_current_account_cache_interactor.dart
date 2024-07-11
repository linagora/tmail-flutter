import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_current_account_cache_state.dart';

class GetCurrentAccountCacheInteractor {
  final AccountRepository _accountRepository;

  GetCurrentAccountCacheInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute({StateChange? stateChange}) async* {
    try {
      yield Right<Failure, Success>(GetCurrentAccountCacheLoading());
      final currentAccount = await _accountRepository.getCurrentAccount();
      yield Right<Failure, Success>(GetCurrentAccountCacheSuccess(
        currentAccount,
        stateChange));
    } catch (e) {
      yield Left<Failure, Success>(GetCurrentAccountCacheFailure(e));
    }
  }
}
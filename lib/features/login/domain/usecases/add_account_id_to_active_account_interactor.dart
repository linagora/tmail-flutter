import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/login/data/extensions/personal_account_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/add_account_id_to_active_account_state.dart';

class AddAccountIdToActiveAccountInteractor {
  final AccountRepository _accountRepository;

  AddAccountIdToActiveAccountInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, String apiUrl, UserName userName) async* {
    try{
      yield Right(AddAccountIdToActiveAccountLoading());
      final currentAccount = await _accountRepository.getCurrentAccount();
      await _accountRepository.setCurrentAccount(
        currentAccount.addAccountId(
          accountId: accountId,
          apiUrl: apiUrl,
          userName: userName
        )
      );
      yield Right(AddAccountIdToActiveAccountSuccess());
    } catch(e) {
      yield Left(AddAccountIdToActiveAccountFailure(e));
    }
  }
}
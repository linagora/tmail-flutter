import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/extensions/account_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_authentication_account_state.dart';

class UpdateAuthenticationAccountInteractor {
  final AccountRepository _accountRepository;

  UpdateAuthenticationAccountInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, String apiUrl) async* {
    try{
      yield Right(UpdateAuthenticationAccountLoading());
      final currentAccount = await _accountRepository.getCurrentAccount();
      await _accountRepository.setCurrentAccount(currentAccount.fromAccountId(
        accountId: accountId,
        apiUrl: apiUrl
      ));
      yield Right(UpdateAuthenticationAccountSuccess());
    } catch(e) {
      yield Left(UpdateAuthenticationAccountFailure(e));
    }
  }
}
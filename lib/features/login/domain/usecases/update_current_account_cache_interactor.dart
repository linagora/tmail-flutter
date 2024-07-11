import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/login/data/extensions/personal_account_extension.dart';
import 'package:tmail_ui_user/features/login/domain/repository/account_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_current_account_cache_state.dart';

class UpdateCurrentAccountCacheInteractor {
  final AccountRepository _accountRepository;

  UpdateCurrentAccountCacheInteractor(this._accountRepository);

  Stream<Either<Failure, Success>> execute(Session session) async* {
    try{
      yield Right(UpdateCurrentAccountCacheLoading());

      final currentAccount = await _accountRepository.getCurrentAccount();
      final apiUrl = session.getQualifiedApiUrl(baseUrl: currentAccount.baseUrl);

      await _accountRepository.setCurrentAccount(
        currentAccount.updateAccountId(
          accountId: session.accountId,
          apiUrl: apiUrl,
          userName: session.username
        )
      );

      yield Right(UpdateCurrentAccountCacheSuccess(
        session: session,
        apiUrl: apiUrl));
    } catch(e) {
      yield Left(UpdateCurrentAccountCacheFailure(e));
    }
  }
}
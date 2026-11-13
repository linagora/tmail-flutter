import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegated_accounts_state.dart';

class GetDelegatedAccountsInteractor {
  final DelegatedAccountRepository _repository;

  GetDelegatedAccountsInteractor(this._repository);

  /// Always acts on my personal account: the server refuses a delegated one.
  Stream<Either<Failure, Success>> execute(Session session) async* {
    try {
      yield Right(GettingDelegatedAccounts());
      final delegatedAccounts = await _repository.getDelegatedAccounts(session.accountId);
      yield Right(GetDelegatedAccountsSuccess(delegatedAccounts));
    } catch (e) {
      yield Left(GetDelegatedAccountsFailure(e));
    }
  }
}

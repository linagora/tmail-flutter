import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/remove_delegated_account_state.dart';

class RemoveDelegatedAccountInteractor {
  final DelegatedAccountRepository _repository;

  RemoveDelegatedAccountInteractor(this._repository);

  /// Always acts on my personal account: the server refuses a delegated one.
  Stream<Either<Failure, Success>> execute(
    Session session,
    DelegatedAccount delegatedAccount,
  ) async* {
    try {
      yield Right(RemovingDelegatedAccount());
      await _repository.removeDelegatedAccount(session.accountId, delegatedAccount.id);
      yield Right(RemoveDelegatedAccountSuccess(delegatedAccount));
    } catch (e) {
      yield Left(RemoveDelegatedAccountFailure(e));
    }
  }
}

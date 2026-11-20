import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegate.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/remove_delegate_state.dart';

class RemoveDelegateInteractor {
  final DelegateRepository _repository;

  RemoveDelegateInteractor(this._repository);

  /// Always acts on my personal account: the server refuses a delegated one.
  Stream<Either<Failure, Success>> execute(Session session, Delegate delegate) async* {
    try {
      yield Right(RemovingDelegate());
      final result = await _repository.removeDelegate(session.accountId, delegate);
      yield Right(RemoveDelegateSuccess(result));
    } catch (e) {
      yield Left(RemoveDelegateFailure(e));
    }
  }
}

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/add_delegates_state.dart';

class AddDelegatesInteractor {
  final DelegateRepository _repository;

  AddDelegatesInteractor(this._repository);

  /// Always acts on my personal account: the server refuses a delegated one.
  Stream<Either<Failure, Success>> execute(Session session, Set<String> usernames) async* {
    try {
      yield Right(AddingDelegates());
      final result = await _repository.addDelegates(session.accountId, usernames);
      yield Right(AddDelegatesSuccess(result));
    } catch (e) {
      yield Left(AddDelegatesFailure(e));
    }
  }
}

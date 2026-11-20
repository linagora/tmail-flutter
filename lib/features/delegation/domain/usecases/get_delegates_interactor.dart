import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegates_state.dart';

class GetDelegatesInteractor {
  final DelegateRepository _repository;

  GetDelegatesInteractor(this._repository);

  /// Always acts on my personal account: the server refuses a delegated one.
  Stream<Either<Failure, Success>> execute(Session session) async* {
    try {
      yield Right(GettingDelegates());
      final delegates = await _repository.getDelegates(session.accountId);
      yield Right(GetDelegatesSuccess(delegates));
    } catch (e) {
      yield Left(GetDelegatesFailure(e));
    }
  }
}

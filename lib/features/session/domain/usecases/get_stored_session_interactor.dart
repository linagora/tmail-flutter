import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_stored_session_state.dart';

class GetStoredSessionInteractor {
  final SessionRepository sessionRepository;

  GetStoredSessionInteractor(this.sessionRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetStoredSessionLoading());
      final session = await sessionRepository.getStoredSession();
      yield Right<Failure, Success>(GetStoredSessionSuccess(session));
    } catch (e) {
      yield Left<Failure, Success>(GetStoredSessionFailure(e));
    }
  }
}
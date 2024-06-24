import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/synchronize_latest_session_state.dart';

class SynchronizeLatestSessionInteractor {
  final SessionRepository _sessionRepository;

  SynchronizeLatestSessionInteractor(this._sessionRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(SynchronizingLatestSession());
      final newSession = await _sessionRepository.getSession();
      await _sessionRepository.storeSession(newSession);
      yield Right<Failure, Success>(SynchronizeLatestSessionSuccess(newSession));
    } catch (e) {
      yield Left<Failure, Success>(SynchronizeLatestSessionFailure(e));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';

class GetSessionInteractor {
  final SessionRepository sessionRepository;

  GetSessionInteractor(this.sessionRepository);

  Stream<Either<Failure, Success>> execute({StateChange? stateChange}) async* {
    try {
      yield Right<Failure, Success>(GetSessionLoading());
      final session = await sessionRepository.getSession();
      yield Right<Failure, Success>(GetSessionSuccess(session, stateChange: stateChange));
    } catch (e) {
      if (PlatformInfo.isMobile) {
        yield* _getStoredSessionFromCache(remoteException: e, stateChange: stateChange);
      } else {
        yield Left<Failure, Success>(GetSessionFailure(e));
      }
    }
  }

  Stream<Either<Failure, Success>> _getStoredSessionFromCache({
    dynamic remoteException,
    StateChange? stateChange
  }) async* {
    try {
      log('GetSessionInteractor::_getStoredSessionFromCache:remoteException: $remoteException');
      yield Right<Failure, Success>(GetSessionLoading());
      final session = await sessionRepository.getStoredSession();
      yield Right<Failure, Success>(GetSessionSuccess(session, stateChange: stateChange));
    } catch (e) {
      yield Left<Failure, Success>(GetSessionFailure(remoteException ?? e));
    }
  }
}
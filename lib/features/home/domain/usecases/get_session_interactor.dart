import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';

class GetSessionInteractor {
  final SessionRepository sessionRepository;

  GetSessionInteractor(this.sessionRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      yield Right<Failure, Success>(GetSessionLoading());
      final session = await sessionRepository.getSession();
      yield Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      if (PlatformInfo.isMobile) {
        yield* _getStoredSessionFromCache(remoteException: e);
      } else {
        yield Left<Failure, Success>(GetSessionFailure(exception: e));
      }
    }
  }

  Stream<Either<Failure, Success>> _getStoredSessionFromCache({dynamic remoteException}) async* {
    try {
      log('GetSessionInteractor::_getStoredSessionFromCache:');
      yield Right<Failure, Success>(GetSessionLoading());
      final session = await sessionRepository.getStoredSession();
      yield Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      yield Left<Failure, Success>(GetSessionFailure(
        exception: e,
        remoteException: remoteException
      ));
    }
  }
}
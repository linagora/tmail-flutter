import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';

class GetSessionInteractor {
  final SessionRepository sessionRepository;

  GetSessionInteractor(this.sessionRepository);

  Stream<Either<Failure, Success>> execute({AccountId? accountId, UserName? userName}) async* {
    try {
      yield Right<Failure, Success>(GetSessionLoading());
      final session = await sessionRepository.getSession();
      yield Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      if (PlatformInfo.isMobile && accountId != null && userName != null) {
        yield* _getStoredSessionFromCache(
          accountId: accountId,
          userName: userName,
          remoteException: e
        );
      } else {
        yield Left<Failure, Success>(GetSessionFailure(e));
      }
    }
  }

  Stream<Either<Failure, Success>> _getStoredSessionFromCache({
    required AccountId accountId,
    required UserName userName,
    dynamic remoteException
  }) async* {
    try {
      log('GetSessionInteractor::_getStoredSessionFromCache:remoteException: $remoteException');
      yield Right<Failure, Success>(GetSessionLoading());
      final session = await sessionRepository.getStoredSession(accountId, userName);
      yield Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      yield Left<Failure, Success>(GetSessionFailure(remoteException ?? e));
    }
  }
}
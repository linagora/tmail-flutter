import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/state/store_session_state.dart';

class StoreSessionInteractor {
  final SessionRepository sessionRepository;

  StoreSessionInteractor(this.sessionRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    UserName userName
  ) async* {
    try {
      yield Right<Failure, Success>(StoreSessionLoading());
      await sessionRepository.storeSession(session, accountId, userName);
      yield Right<Failure, Success>(StoreSessionSuccess());
    } catch (e) {
      yield Left<Failure, Success>(StoreSessionFailure(e));
    }
  }
}
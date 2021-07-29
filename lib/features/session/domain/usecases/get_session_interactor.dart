import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';

class GetSessionInteractor {
  final SessionRepository sessionRepository;

  GetSessionInteractor(this.sessionRepository);

  Future<Either<Failure, Success>> execute() async {
    try {
      final session = await sessionRepository.getSession();
      return Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      return Left<Failure, Success>(GetSessionFailure(e));
    }
  }
}
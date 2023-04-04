import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/session/domain/state/get_session_state.dart';

class GetSessionInteractor {
  final SessionRepository sessionRepository;

  GetSessionInteractor(this.sessionRepository);

  Stream<Either<Failure, Success>> execute() async* {
    try {
      final session = await sessionRepository.getSession();
      yield Right<Failure, Success>(GetSessionSuccess(session));
    } catch (e) {
      yield Left<Failure, Success>(GetSessionFailure(e));
    }
  }
}
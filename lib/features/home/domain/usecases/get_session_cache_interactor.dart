import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_cache_state.dart';

class GetSessionCacheInteractor {
  final SessionRepository _sessionRepository;

  GetSessionCacheInteractor(this._sessionRepository);

  Stream<Either<Failure, Success>> execute(PersonalAccount personalAccount) async* {
    try {
      yield Right<Failure, Success>(GetSessionCacheLoading());
      final sessionCache = await _sessionRepository.getStoredSession();
      yield Right<Failure, Success>(GetSessionCacheSuccess(
        session: sessionCache,
        personalAccount: personalAccount));
    } catch (e) {
      yield Left<Failure, Success>(GetSessionCacheFailure(
        personalAccount: personalAccount,
        exception: e));
    }
  }
}
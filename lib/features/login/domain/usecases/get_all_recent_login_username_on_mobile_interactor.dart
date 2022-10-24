import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_username_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_username_state.dart';

class GetAllRecentLoginUsernameOnMobileInteractor {
  final LoginUsernameRepository loginUsernameRepository;

  GetAllRecentLoginUsernameOnMobileInteractor(this.loginUsernameRepository);

  Future<Either<Failure, Success>> execute({int? limit, String? pattern}) async {
    try {
      final listRecent = await loginUsernameRepository.getAllRecentLoginUsernameLatest(
          limit: limit, pattern: pattern);
      return Right(GetAllRecentLoginUsernameLatestSuccess(listRecent));
    } catch (exception) {
      return Left(GetAllRecentLoginUsernameLatestFailure(exception));
    }
  }
}

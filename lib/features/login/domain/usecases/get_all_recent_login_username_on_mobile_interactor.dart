import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_username_state.dart';

class GetAllRecentLoginUsernameOnMobileInteractor {
  final LoginRepository _loginRepository;

  GetAllRecentLoginUsernameOnMobileInteractor(this._loginRepository);

  Future<Either<Failure, Success>> execute({int? limit, String? pattern}) async {
    try {
      final listRecent = await _loginRepository.getAllRecentLoginUsernameLatest(
        limit: limit,
        pattern: pattern
      );
      return Right(GetAllRecentLoginUsernameLatestSuccess(listRecent));
    } catch (exception) {
      return Left(GetAllRecentLoginUsernameLatestFailure(exception));
    }
  }
}

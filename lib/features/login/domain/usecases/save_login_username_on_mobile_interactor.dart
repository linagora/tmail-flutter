import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/save_recent_login_username_state.dart';

class SaveLoginUsernameOnMobileInteractor {
  final LoginRepository _loginRepository;

  SaveLoginUsernameOnMobileInteractor(this._loginRepository);

  Future<Either<Failure, Success>> execute(RecentLoginUsername recentLoginUsername) async {
    try {
      await _loginRepository.saveLoginUsername(recentLoginUsername);
      return Right(SaveRecentLoginUsernameSuccess());
    } catch(exception) {
      return Left(SaveRecentLoginUsernameFailed(exception));
    }
  }
}
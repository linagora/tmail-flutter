import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_username_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/save_recent_login_username_state.dart';

class SaveLoginUsernameOnMobileInteractor {
  final LoginUsernameRepository loginUsernameRepository;

  SaveLoginUsernameOnMobileInteractor(this.loginUsernameRepository);

  Stream<Either<Failure, Success>> execute(RecentLoginUsername recentLoginUsername) async* {
    try {
      await loginUsernameRepository.saveLoginUsername(recentLoginUsername);
      yield Right(SaveRecentLoginUsernameSuccess());
    } catch(exception) {
      yield Left(SaveRecentLoginUsernameFailed(exception));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/save_recent_login_url_state.dart';

class SaveLoginUrlOnMobileInteractor {
  final LoginRepository _loginRepository;

  SaveLoginUrlOnMobileInteractor(this._loginRepository);

  Future<Either<Failure, Success>> execute(RecentLoginUrl recentLoginUrl) async {
    try{
      await _loginRepository.saveRecentLoginUrl(recentLoginUrl);
      return Right(SaveRecentLoginUrlSuccess());
    } catch(e) {
      return Left(SaveRecentLoginUrlFailed(e));
    }
  }
}
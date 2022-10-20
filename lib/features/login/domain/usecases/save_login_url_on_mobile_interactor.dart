import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_url_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/save_recent_login_url_state.dart';

class SaveLoginUrlOnMobileInteractor {
  final LoginUrlRepository loginUrlRepository;

  SaveLoginUrlOnMobileInteractor(this.loginUrlRepository);

  Stream<Either<Failure, Success>> execute(RecentLoginUrl recentLoginUrl) async* {
    try{
      await loginUrlRepository.saveRecentLoginUrl(recentLoginUrl);
      yield Right(SaveRecentLoginUrlSuccess());
    } catch(e) {
      yield Left(SaveRecentLoginUrlFailed(e));
    }
  }
}
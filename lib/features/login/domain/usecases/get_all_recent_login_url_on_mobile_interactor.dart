import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/login/domain/repository/login_url_repository.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_url_latest_state.dart';

class GetAllRecentLoginUrlOnMobileInteractor {
  final LoginUrlRepository _loginUrlRepository;

  GetAllRecentLoginUrlOnMobileInteractor(this._loginUrlRepository);

  Future<Either<Failure, Success>> execute({int? limit, String? pattern}) async {
    try{
      final listRecentUrl = await _loginUrlRepository.getAllRecentLoginUrlLatest(
          limit: limit,
          pattern: pattern);
      return Right(GetAllRecentLoginUrlLatestSuccess(listRecentUrl));
    } catch(e) {
      return Left(GetAllRecentLoginUrlLatestFailure(e));
    }
  }
}
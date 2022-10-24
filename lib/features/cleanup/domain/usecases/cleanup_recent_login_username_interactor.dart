import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/state/cleanup_recent_login_username_cache_state.dart';

class CleanupRecentLoginUsernameCacheInteractor {
  final CleanupRepository cleanupRepository;

  CleanupRecentLoginUsernameCacheInteractor(this.cleanupRepository);

  Future<Either<Failure, Success>> execute(RecentLoginUsernameCleanupRule cleanupRule) async {
    try {
      await cleanupRepository.cleanRecentLoginUsernameCache(cleanupRule);
      return Right<Failure, Success>(CleanupRecentLoginUsernameCacheSuccess());
    } catch (e) {
      return Left(CleanupRecentLoginUsernameCacheFailure(e));
    }
  }
}
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/state/cleanup_recent_login_url_cache_state.dart';

class CleanupRecentLoginUrlCacheInteractor {
  final CleanupRepository cleanupRepository;

  CleanupRecentLoginUrlCacheInteractor(this.cleanupRepository);

  Future<Either<Failure, Success>> execute(RecentLoginUrlCleanupRule cleanupRule) async {
    try {
      await cleanupRepository.cleanRecentLoginUrlCache(cleanupRule);
      return Right<Failure, Success>(CleanupRecentLoginUrlCacheSuccess());
    } catch (e) {
      return Left(CleanupRecentLoginUrlCacheFailure(e));
    }
  }
}
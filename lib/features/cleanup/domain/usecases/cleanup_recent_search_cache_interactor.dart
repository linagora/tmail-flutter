import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/state/cleanup_recent_search_cache_state.dart';

class CleanupRecentSearchCacheInteractor {
  final CleanupRepository cleanupRepository;

  CleanupRecentSearchCacheInteractor(this.cleanupRepository);

  Future<Either<Failure, Success>> execute(RecentSearchCleanupRule cleanupRule) async {
    try {
      await cleanupRepository.cleanRecentSearchCache(cleanupRule);
      log('CleanupRecentSearchCacheInteractor::execute(): SUCCESS');
      return Right<Failure, Success>(CleanupRecentSearchCacheSuccess());
    } catch (e) {
      return Left(CleanupRecentSearchCacheFailure(e));
    }
  }
}
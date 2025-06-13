import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/state/cleanup_recent_search_cache_state.dart';

class CleanupRecentSearchCacheInteractor {
  final CleanupRepository cleanupRepository;

  CleanupRecentSearchCacheInteractor(this.cleanupRepository);

  Stream<Either<Failure, Success>> execute(RecentSearchCleanupRule cleanupRule) async* {
    try {
      yield Right<Failure, Success>(CleanupRecentSearchCacheLoading());
      await cleanupRepository.cleanRecentSearchCache(cleanupRule);
      yield Right<Failure, Success>(CleanupRecentSearchCacheSuccess());
    } catch (e) {
      yield Left(CleanupRecentSearchCacheFailure(e));
    }
  }
}
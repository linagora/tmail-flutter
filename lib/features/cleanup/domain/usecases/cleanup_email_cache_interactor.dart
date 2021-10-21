import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/repository/cleanup_repository.dart';
import 'package:tmail_ui_user/features/cleanup/domain/state/cleanup_email_cache_state.dart';

class CleanupEmailCacheInteractor {
  final CleanupRepository cleanupRepository;

  CleanupEmailCacheInteractor(this.cleanupRepository);

  Future<Either<Failure, Success>> execute(CleanupRule cleanupRule) async {
    try {
      await cleanupRepository.cleanEmailCache(cleanupRule);
      return Right<Failure, Success>(CleanupEmailCacheSuccess());
    } catch (e) {
      return Left(CleanupEmailCacheFailure(e));
    }
  }
}
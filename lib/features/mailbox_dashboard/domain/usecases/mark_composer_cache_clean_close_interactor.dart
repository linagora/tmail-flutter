import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/mark_composer_cache_clean_close_state.dart';

/// Two-step write (mark then remove) ensures the entry is not treated as a
/// recoverable snapshot if removal is interrupted
/// (see [ComposerPersistentCache.isRestorable]).
class MarkComposerCacheCleanCloseInteractor {
  final ComposerCacheRepository _repository;

  MarkComposerCacheCleanCloseInteractor(this._repository);

  Future<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
  ) async {
    try {
      final cache =
          (await _repository.getComposerCache(accountId, userName)).newestLocalCache;
      if (cache != null) await _tryMarkCleanClose(accountId, userName, cache);
      await _repository.removeAllComposerCache(accountId, userName);
      return Right(MarkComposerCacheCleanCloseSuccess());
    } catch (exception) {
      return Left(MarkComposerCacheCleanCloseFailure(exception));
    }
  }

  Future<void> _tryMarkCleanClose(
    AccountId accountId,
    UserName userName,
    ComposerPersistentCache cache,
  ) async {
    try {
      await _repository.saveComposerCache(
        accountId,
        userName,
        cache.copyWith(isCleanClose: true),
      );
    } catch (_) {
      // Best-effort: mark failure must not prevent removal.
    }
  }
}

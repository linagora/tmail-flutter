import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/resolve_composer_cache_for_restore_state.dart';

part 'resolve_composer_cache_for_restore_interactor.g.dart';

/// Fetches, validates, and cleans up the composer cache in one pass.
///
/// Returns [ResolveComposerCacheForRestoreSuccess] with a non-null [cache]
/// when a restorable snapshot exists.  Stale or clean-close entries are
/// removed as a side-effect so Hive stays lean.
class ResolveComposerCacheForRestoreInteractor {
  final ComposerCacheRepository _repository;

  ResolveComposerCacheForRestoreInteractor(this._repository);

  Future<Either<Failure, Success>> execute(
    AccountId accountId,
    UserName userName,
  ) async {
    try {
      final caches = await _repository.getComposerCache(accountId, userName);
      final cache = caches.newestLocalCache;

      if (cache == null) {
        return Right(ResolveComposerCacheForRestoreSuccess(null));
      }

      if (!cache.isRestorable) {
        await _repository.removeAllComposerCache(accountId, userName);
        return Right(ResolveComposerCacheForRestoreSuccess(null));
      }

      return Right(ResolveComposerCacheForRestoreSuccess(cache));
    } catch (exception) {
      return Left(ResolveComposerCacheForRestoreFailure(exception));
    }
  }
}

@Riverpod(keepAlive: true)
ResolveComposerCacheForRestoreInteractor resolveComposerCacheForRestore(Ref ref) =>
    ResolveComposerCacheForRestoreInteractor(ref.watch(composerCacheRepositoryProvider));

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/mark_composer_cache_clean_close_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/resolve_composer_cache_for_restore_interactor.dart';

part 'composer_cache_interactor_providers.g.dart';

@riverpod
RemoveAllComposerCacheInteractor removeAllComposerCache(Ref ref) =>
    RemoveAllComposerCacheInteractor(ref.watch(composerCacheRepositoryProvider));

@riverpod
MarkComposerCacheCleanCloseInteractor markComposerLocalCacheCleanClose(Ref ref) =>
    MarkComposerCacheCleanCloseInteractor(ref.watch(composerCacheRepositoryProvider));

@riverpod
ResolveComposerCacheForRestoreInteractor resolveComposerCacheForRestore(Ref ref) =>
    ResolveComposerCacheForRestoreInteractor(ref.watch(composerCacheRepositoryProvider));

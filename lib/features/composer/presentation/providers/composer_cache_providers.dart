import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_persistent_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/mark_composer_cache_clean_close_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_all_composer_cache_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/resolve_composer_cache_for_restore_interactor.dart';
import 'package:tmail_ui_user/main/providers/cache_exception_thrower_provider.dart';

final _composerHiveCacheClientProvider =
    Provider<ComposerHiveCacheClient>((_) => ComposerHiveCacheClient());

final _composerCacheDatasourceProvider = Provider<ComposerCacheDatasource>(
  (ref) => ComposerPersistentCacheDatasourceImpl(
    ref.read(_composerHiveCacheClientProvider),
    ref.read(cacheExceptionThrowerProvider),
  ),
);

final composerCacheRepositoryProvider = Provider<ComposerCacheRepository>(
  (ref) => ComposerCacheRepositoryImpl(ref.read(_composerCacheDatasourceProvider)),
);

final removeAllComposerCacheProvider = Provider<RemoveAllComposerCacheInteractor>(
  (ref) => RemoveAllComposerCacheInteractor(ref.read(composerCacheRepositoryProvider)),
);

final markComposerLocalCacheCleanCloseProvider = Provider<MarkComposerCacheCleanCloseInteractor>(
  (ref) => MarkComposerCacheCleanCloseInteractor(ref.read(composerCacheRepositoryProvider)),
);

final resolveComposerCacheForRestoreProvider = Provider<ResolveComposerCacheForRestoreInteractor>(
  (ref) => ResolveComposerCacheForRestoreInteractor(ref.read(composerCacheRepositoryProvider)),
);

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_persistent_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/composer_cache_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';
import 'package:tmail_ui_user/main/providers/thrower/cache_exception_thrower_provider.dart';

part 'composer_cache_data_providers.g.dart';

@Riverpod(keepAlive: true)
ComposerHiveCacheClient composerHiveCacheClient(Ref ref) =>
    ComposerHiveCacheClient();

@Riverpod(keepAlive: true)
ComposerCacheDatasource composerCacheDatasource(Ref ref) =>
    ComposerPersistentCacheDatasourceImpl(
      ref.watch(composerHiveCacheClientProvider),
      ref.watch(cacheExceptionThrowerProvider),
    );

@Riverpod(keepAlive: true)
ComposerCacheRepository composerCacheRepository(Ref ref) =>
    ComposerCacheRepositoryImpl(ref.watch(composerCacheDatasourceProvider));

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_persistent_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

part 'composer_cache_repository_impl.g.dart';

class ComposerCacheRepositoryImpl extends ComposerCacheRepository {
  final ComposerCacheDatasource _composerCacheDatasource;

  ComposerCacheRepositoryImpl(this._composerCacheDatasource);

  @override
  Future<void> saveComposerCache(
    AccountId accountId,
    UserName userName,
    ComposerCache composerCache,
  ) =>
      _composerCacheDatasource.saveComposerCache(
        accountId,
        userName,
        composerCache,
      );

  @override
  Future<List<ComposerCache>> getComposerCache(
    AccountId accountId,
    UserName userName,
  ) =>
      _composerCacheDatasource.getComposerCache(accountId, userName);

  @override
  Future<void> removeAllComposerCache(
    AccountId accountId,
    UserName userName,
  ) =>
      _composerCacheDatasource.removeAllComposerCache(accountId, userName);

  @override
  Future<void> removeComposerCacheById(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) =>
      _composerCacheDatasource.removeComposerCacheById(
        accountId,
        userName,
        composerId,
      );
}

@Riverpod(keepAlive: true)
ComposerCacheRepository composerCacheRepository(Ref ref) =>
    ComposerCacheRepositoryImpl(ref.watch(composerCacheDatasourceProvider));

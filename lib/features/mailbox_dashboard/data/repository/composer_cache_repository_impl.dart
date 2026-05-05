import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

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

  @override
  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID,
  ) =>
      _composerCacheDatasource.restoreEmailInlineImages(
        htmlContent,
        transformConfiguration,
        mapUrlDownloadCID,
      );
}

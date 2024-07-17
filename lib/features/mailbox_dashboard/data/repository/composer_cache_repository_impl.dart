import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class ComposerCacheRepositoryImpl extends ComposerCacheRepository {

  final SessionStorageComposerDatasource composerCacheDataSource;

  ComposerCacheRepositoryImpl(this.composerCacheDataSource);

  @override
  Future<ComposerCache> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName
  ) {
    return composerCacheDataSource.getComposerCacheOnWeb(accountId, userName);
  }

  @override
  Future<void> removeComposerCacheOnWeb() {
    return composerCacheDataSource.removeComposerCacheOnWeb();
  }

  @override
  Future<void> saveComposerCacheOnWeb({
    required AccountId accountId,
    required UserName userName,
    required ComposerCache composerCache,
  }) {
    return composerCacheDataSource.saveComposerCacheOnWeb(
      accountId: accountId,
      userName: userName,
      composerCache: composerCache);
  }

  @override
  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID) {
    return composerCacheDataSource.restoreEmailInlineImages(
      htmlContent,
      transformConfiguration,
      mapUrlDownloadCID);
  }
}
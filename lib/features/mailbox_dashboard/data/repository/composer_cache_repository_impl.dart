import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_storage_browser_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class ComposerCacheRepositoryImpl extends ComposerCacheRepository {

  final SessionStorageComposerDatasource _sessionStorageComposerDatasource;
  final LocalStorageBrowserDatasource _localStorageBrowserDatasource;
  final HtmlDataSource _htmlDataSource;

  ComposerCacheRepositoryImpl(
    this._sessionStorageComposerDatasource,
    this._localStorageBrowserDatasource,
    this._htmlDataSource,
  );

  @override
  Future<ComposerCache> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName
  ) {
    return _sessionStorageComposerDatasource.getComposerCache(accountId, userName);
  }

  @override
  Future<void> removeComposerCacheOnWeb() {
    return _sessionStorageComposerDatasource.deleteComposerCache();
  }

  @override
  Future<void> saveComposerCacheOnWeb(
    ComposerCache composerCache,
    AccountId accountId,
    UserName userName
  ) {
    return _sessionStorageComposerDatasource.saveComposerCache(
      composerCache,
      accountId,
      userName);
  }

  @override
  Future<String> convertImageCIDToBase64(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID
  ) {
    return _htmlDataSource.convertImageCIDToBase64(
      htmlContent,
      transformConfiguration,
      mapUrlDownloadCID);
  }

  @override
  Future<void> deleteComposerCacheInLocalStorageBrowser() {
    return _localStorageBrowserDatasource.deleteComposerCache();
  }

  @override
  Future<ComposerCache> getComposerCacheInLocalStorageBrowser(
    AccountId accountId,
    UserName userName
  ) {
    return _localStorageBrowserDatasource.getComposerCache(accountId, userName);
  }

  @override
  Future<void> saveComposerCacheToLocalStorageBrowser(
    ComposerCache composerCache,
    AccountId accountId,
    UserName userName
  ) {
    return _localStorageBrowserDatasource.saveComposerCache(
      composerCache,
      accountId,
      userName);
  }
}
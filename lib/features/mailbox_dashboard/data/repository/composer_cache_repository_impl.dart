import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_storage_browser_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/composer_cache_repository.dart';

class ComposerCacheRepositoryImpl extends ComposerCacheRepository {

  final SessionStorageComposerDatasource composerCacheDataSource;
  final LocalStorageBrowserDatasource _localStorageBrowserDatasource;

  ComposerCacheRepositoryImpl(
    this.composerCacheDataSource,
    this._localStorageBrowserDatasource,
  );

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
  Future<void> saveComposerCacheOnWeb(
    Email email,
    {
      required AccountId accountId,
      required UserName userName,
      required ScreenDisplayMode displayMode,
      Identity? identity,
      bool? readReceipentEnabled
    }
  ) {
    return composerCacheDataSource.saveComposerCacheOnWeb(
      email,
      accountId: accountId,
      userName: userName,
      displayMode: displayMode,
      identity: identity,
      readReceipentEnabled: readReceipentEnabled);
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

  @override
  Future<Email> getComposedEmailFromLocalStorageBrowser() {
    return _localStorageBrowserDatasource.getComposedEmail();
  }

  @override
  Future<void> storeComposedEmailToLocalStorageBrowser(Email email) {
    return _localStorageBrowserDatasource.storeComposedEmail(email);
  }

  @override
  Future<void> deleteComposedEmailOnLocalStorageBrowser() {
    return _localStorageBrowserDatasource.deleteComposedEmail();
  }
}
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class ComposerCacheRepository {
  Future<void> saveComposerCacheOnWeb(
    ComposerCache composerCache,
    AccountId accountId,
    UserName userName);

  Future<ComposerCache> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName);

  Future<void> removeComposerCacheOnWeb();

  Future<String> convertImageCIDToBase64(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID);

  Future<void> saveComposerCacheToLocalStorageBrowser(
    ComposerCache composerCache,
    AccountId accountId,
    UserName userName);

  Future<ComposerCache> getComposerCacheInLocalStorageBrowser(
    AccountId accountId,
    UserName userName);

  Future<void> deleteComposerCacheInLocalStorageBrowser();
}

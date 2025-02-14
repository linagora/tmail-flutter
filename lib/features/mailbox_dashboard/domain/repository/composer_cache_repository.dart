import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class ComposerCacheRepository {
  Future<void> saveComposerCacheOnWeb({
    required AccountId accountId,
    required UserName userName,
    required ComposerCache composerCache,
  });

  Future<List<ComposerCache>> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName);

  Future<void> removeAllComposerCacheOnWeb(
    AccountId accountId,
    UserName userName,
  );

  Future<void> removeComposerCacheByIdOnWeb(
    AccountId accountId,
    UserName userName,
    String composerId,
  );

  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID);
}

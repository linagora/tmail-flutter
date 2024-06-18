import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class ComposerCacheRepository {
  Future<void> saveComposerCacheOnWeb(
    Email email,
    {
      required AccountId accountId,
      required UserName userName,
      required ScreenDisplayMode displayMode,
      Identity? identity,
      bool? readReceipentEnabled
    }
  );

  Future<ComposerCache> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName);

  Future<void> removeComposerCacheOnWeb();

  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID);
}

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class ComposerCacheRepository {
  Future<void> saveComposerCache(
    AccountId accountId,
    UserName userName,
    ComposerCache composerCache,
  );

  Future<List<ComposerCache>> getComposerCache(
    AccountId accountId,
    UserName userName,
  );

  Future<void> removeAllComposerCache(
    AccountId accountId,
    UserName userName,
  );

  Future<void> removeComposerCacheById(
    AccountId accountId,
    UserName userName,
    String composerId,
  );
}

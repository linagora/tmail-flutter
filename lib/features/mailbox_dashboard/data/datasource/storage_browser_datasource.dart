import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class StorageBrowserDatasource {
  String generateComposerCacheKey(AccountId accountId, UserName userName);

  Future<void> saveComposerCache(ComposerCache composerCache, AccountId accountId, UserName userName);

  Future<ComposerCache> getComposerCache(AccountId accountId, UserName userName);

  Future<void> deleteComposerCache();
}
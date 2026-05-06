import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';

abstract class ComposerCacheDatasource {
  Future<void> saveComposerCache(
    AccountId accountId,
    UserName userName,
    ComposerCache composerCache,
  ) =>
      throw UnsupportedError(
          'saveComposerCache is not supported on this platform');

  Future<List<ComposerCache>> getComposerCache(
    AccountId accountId,
    UserName userName,
  ) =>
      throw UnsupportedError(
          'getComposerCache is not supported on this platform');

  Future<void> removeAllComposerCache(
    AccountId accountId,
    UserName userName,
  ) =>
      throw UnsupportedError(
          'removeAllComposerCache is not supported on this platform');

  Future<void> removeComposerCacheById(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) =>
      throw UnsupportedError(
          'removeComposerCacheById is not supported on this platform');

}

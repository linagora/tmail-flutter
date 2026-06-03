import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class ComposerPersistentCacheDatasourceImpl extends ComposerCacheDatasource {
  final ComposerHiveCacheClient _cacheClient;
  final ExceptionThrower _exceptionThrower;

  ComposerPersistentCacheDatasourceImpl(this._cacheClient, this._exceptionThrower);

  @override
  Future<void> saveComposerCache(
    AccountId accountId,
    UserName userName,
    ComposerCache composerCache,
  ) {
    return Future.sync(
      () => _cacheClient.saveCache(accountId, userName, composerCache),
    ).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<ComposerCache>> getComposerCache(
    AccountId accountId,
    UserName userName,
  ) {
    return Future.sync(
      () => _cacheClient.getCache(accountId, userName),
    ).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeAllComposerCache(AccountId accountId, UserName userName) {
    return Future.sync(
      () => _cacheClient.deleteCache(accountId, userName),
    ).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeComposerCacheById(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) {
    return Future.sync(
      () => _cacheClient.deleteCacheById(accountId, userName, composerId),
    ).catchError(_exceptionThrower.throwException);
  }
}

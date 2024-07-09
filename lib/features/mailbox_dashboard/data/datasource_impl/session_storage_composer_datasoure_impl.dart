import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/storage_browser_exception.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

class SessionStorageComposerDatasourceImpl extends SessionStorageComposerDatasource {
  final ExceptionThrower _exceptionThrower;

  SessionStorageComposerDatasourceImpl(this._exceptionThrower);

  @override
  String generateComposerCacheKey(AccountId accountId, UserName userName) {
    return TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value).toString();
  }

  @override
  Future<void> deleteComposerCache() {
    return Future.sync(() async {
      return html.window.sessionStorage.removeWhere((key, value) =>
          key.startsWith(EmailActionType.reopenComposerBrowser.name));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<ComposerCache> getComposerCache(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final storageKey = generateComposerCacheKey(accountId, userName);

      final result = html.window.sessionStorage.entries
          .firstWhereOrNull((entry) => entry.key == storageKey);

      if (result != null) {
        return ComposerCache.fromJson(jsonDecode(result.value));
      } else {
        throw NotFoundDataInStorageBrowserException();
      }
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveComposerCache(ComposerCache composerCache, AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final storageKey = generateComposerCacheKey(accountId, userName);

      Map<String, String> entries = {
        storageKey: jsonEncode(composerCache.toJson())
      };

      return html.window.sessionStorage.addAll(entries);
    }).catchError(_exceptionThrower.throwException);
  }
}

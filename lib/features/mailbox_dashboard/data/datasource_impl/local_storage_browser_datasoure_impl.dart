import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_storage_browser_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/storage_browser_exception.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

class LocalStorageBrowserDatasourceImpl extends LocalStorageBrowserDatasource {
  final ExceptionThrower _exceptionThrower;

  LocalStorageBrowserDatasourceImpl(this._exceptionThrower);

  @override
  String generateComposerCacheKey(AccountId accountId, UserName userName) {
    return TupleKey(
      EmailActionType.composeEmailIntoNewTab.name,
      accountId.asString,
      userName.value).toString();
  }

  @override
  Future<void> deleteComposerCache() {
    return Future.sync(() async {
      return html.window.localStorage.removeWhere((key, value) =>
          key.startsWith(EmailActionType.composeEmailIntoNewTab.name));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<ComposerCache> getComposerCache(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final storageKey = generateComposerCacheKey(accountId, userName);

      final result = html.window.localStorage.entries
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

      return html.window.localStorage.addAll(entries);
    }).catchError(_exceptionThrower.throwException);
  }
}

import 'dart:convert';
import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/composer_cache_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

class ComposerSessionCacheDatasourceImpl extends ComposerCacheDatasource {
  final ExceptionThrower _exceptionThrower;

  ComposerSessionCacheDatasourceImpl(this._exceptionThrower);

  @override
  Future<List<ComposerCache>> getComposerCache(
    AccountId accountId,
    UserName userName,
  ) {
    return Future.sync(() async {
      final keyWithIdentity = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value).toString();

      final listEntries = html.window.sessionStorage.entries.where(
        (entry) => entry.key.startsWith(keyWithIdentity),
      );

      if (listEntries.isNotEmpty) {
        return listEntries
          .map((entry) => ComposerCache.fromJson(jsonDecode(entry.value)))
          .toList();
      } else {
        throw const NotFoundInWebSessionException();
      }
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveComposerCache(
    AccountId accountId,
    UserName userName,
    ComposerCache composerCache,
  ) {
    return Future.sync(() {
      final composerCacheKey = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value,
        composerCache.composerId,
      ).toString();
      html.window.sessionStorage[composerCacheKey] = jsonEncode(composerCache.toJson());
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeAllComposerCache(AccountId accountId, UserName userName) {
    return Future.sync(() {
      final keyWithIdentity = _buildKeyPrefix(accountId, userName);
      html.window.sessionStorage.removeWhere((key, value) => key.startsWith(keyWithIdentity));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeComposerCacheById(AccountId accountId, UserName userName, String composerId) {
    return Future.sync(() {
      final composerCacheKey = _buildComposerKey(accountId, userName, composerId);
      html.window.sessionStorage.remove(composerCacheKey);
    }).catchError(_exceptionThrower.throwException);
  }

  String _buildKeyPrefix(AccountId accountId, UserName userName) {
    return TupleKey(
      EmailActionType.reopenComposerBrowser.name,
      accountId.asString,
      userName.value,
    ).toString();
  }

  String _buildComposerKey(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) {
    return TupleKey(
      EmailActionType.reopenComposerBrowser.name,
      accountId.asString,
      userName.value,
      composerId,
    ).toString();
  }
}

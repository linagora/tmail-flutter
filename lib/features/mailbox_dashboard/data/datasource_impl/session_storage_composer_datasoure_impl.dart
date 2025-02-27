import 'dart:convert';
import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

class SessionStorageComposerDatasourceImpl
    extends SessionStorageComposerDatasource {
  SessionStorageComposerDatasourceImpl(this._htmlTransform, this._exceptionThrower);

  final HtmlTransform _htmlTransform;
  final ExceptionThrower _exceptionThrower;

  @override
  Future<List<ComposerCache>> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName
  ) async {
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
        throw NotFoundInWebSessionException();
      }
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveComposerCacheOnWeb({
    required AccountId accountId,
    required UserName userName,
    required ComposerCache composerCache,
  }) async {
    return Future.sync(() {
      final composerCacheKey = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value,
        composerCache.composerId,
      ).toString();
      Map<String, String> entries = {
        composerCacheKey: jsonEncode(composerCache.toJson())
      };
      html.window.sessionStorage.addAll(entries);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<String> restoreEmailInlineImages(
    String htmlContent,
    TransformConfiguration transformConfiguration,
    Map<String, String> mapUrlDownloadCID) {
    return Future.sync(() async {
      return await _htmlTransform.transformToHtml(
        htmlContent: htmlContent,
        transformConfiguration: transformConfiguration,
        mapCidImageDownloadUrl: mapUrlDownloadCID);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeAllComposerCacheOnWeb(AccountId accountId, UserName userName) {
    return Future.sync(() {
      final keyWithIdentity = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value,
      ).toString();

      html.window.sessionStorage.removeWhere((key, value) => key.startsWith(keyWithIdentity));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeComposerCacheByIdOnWeb(AccountId accountId, UserName userName, String composerId) {
    return Future.sync(() {
      final keyWithIdentity = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value,
        composerId,
      ).toString();

      html.window.sessionStorage.removeWhere((key, value) => key == keyWithIdentity);
    }).catchError(_exceptionThrower.throwException);
  }
}

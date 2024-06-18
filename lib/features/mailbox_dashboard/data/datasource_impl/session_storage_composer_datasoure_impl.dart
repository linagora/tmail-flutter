import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
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
  Future<ComposerCache> getComposerCacheOnWeb(
    AccountId accountId,
    UserName userName
  ) async {
    return Future.sync(() async {
      final keyWithIdentity = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value).toString();
        
      final result = html.window.sessionStorage.entries.firstWhereOrNull(
        (entry) => entry.key == keyWithIdentity);
      if (result != null) {
        return ComposerCache.fromJson(jsonDecode(result.value));
      } else {
        throw NotFoundInWebSessionException();
      }
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> removeComposerCacheOnWeb() async {
    return Future.sync(() {
      html.window.sessionStorage.removeWhere(
        (key, value) => key.startsWith(EmailActionType.reopenComposerBrowser.name));
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveComposerCacheOnWeb(
    Email email,
    {
      required AccountId accountId,
      required UserName userName,
      required ScreenDisplayMode displayMode,
      Identity? identity,
      bool? readReceipentEnabled
    }
  ) async {
    return Future.sync(() {
      final composerCacheKey = TupleKey(
        EmailActionType.reopenComposerBrowser.name,
        accountId.asString,
        userName.value).toString();
      Map<String, String> entries = {
        composerCacheKey: jsonEncode(
          ComposerCache(
            displayMode: displayMode,
            email: email,
            identity: identity,
            readReceipentEnabled: readReceipentEnabled,
          ).toJson()
        )
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
}

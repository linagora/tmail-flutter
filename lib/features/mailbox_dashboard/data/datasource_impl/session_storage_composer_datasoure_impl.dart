import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/session_storage_composer_datasource.dart';
import 'package:universal_html/html.dart' as html;

class SessionStorageComposerDatasourceImpl
    extends SessionStorageComposerDatasource {
  @override
  ComposerCache getComposerCacheOnWeb() {
    try {
      final result = html.window.sessionStorage.entries.firstWhereOrNull((e) => e.key == EmailActionType.reopenComposerBrowser.name);
      if (result != null) {
        final emailCache = ComposerCache.fromJson(jsonDecode(result.value));
        return emailCache;
      } else {
        throw NotFoundInWebSessionException();
      }
    } catch (e) {
      throw NotFoundInWebSessionException(errorMessage: e.toString());
    }
  }

  @override
  void removeComposerCacheOnWeb() {
    try {
      html.window.sessionStorage.removeWhere((key, value) => key == EmailActionType.reopenComposerBrowser.name);
    } catch (e) {
      throw NotFoundInWebSessionException(errorMessage: e.toString());
    }
  }

  @override
  void saveComposerCacheOnWeb(Email email) {
    try {
      Map<String, String> entries = {
        EmailActionType.reopenComposerBrowser.name: email.asString()
      };
      html.window.sessionStorage.addAll(entries);
    } catch (e) {
      throw SaveToWebSessionFailException(errorMessage: e.toString());
    }
  }
}

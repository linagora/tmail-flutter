import 'dart:convert';
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
      final result = html.window.sessionStorage.entries
          .where((e) => e.key == EmailActionType.edit.name)
          .toList();
      if (result.isNotEmpty) {
        final jsonHandle =
            json.decode(result.first.value) as Map<String, dynamic>;
        final emailCache = ComposerCache.fromJson(jsonHandle);
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
      html.window.sessionStorage
          .removeWhere((key, value) => key == EmailActionType.edit.name);
    } catch (e) {
      throw NotFoundInWebSessionException(errorMessage: e.toString());
    }
  }

  @override
  void saveComposerCacheOnWeb(Email email) {
    try {
      Map<String, String> entries = {
        EmailActionType.edit.name: json.encode(email.toJson())
      };
      html.window.sessionStorage.addAll(entries);
    } catch (e) {
      throw SaveToWebSessionFailException(errorMessage: e.toString());
    }
  }
}

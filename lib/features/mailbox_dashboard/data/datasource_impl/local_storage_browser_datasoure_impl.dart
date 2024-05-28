import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/local_storage_browser_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/local_storage_browser_exception.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart' as html;

class LocalStorageBrowserDatasourceImpl extends LocalStorageBrowserDatasource {

  static const String composedEmailLocalStorageKey = 'composed-email';

  final ExceptionThrower _exceptionThrower;

  LocalStorageBrowserDatasourceImpl(this._exceptionThrower);

  @override
  Future<void> storeComposedEmail(Email email) {
    return Future.sync(() async {
      return html.window.localStorage.addAll({
        composedEmailLocalStorageKey: email.asString()
      });
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Email> getComposedEmail() {
    return Future.sync(() async {
      final entry = html.window.localStorage.entries.firstWhereOrNull((e) => e.key == composedEmailLocalStorageKey);
      if (entry != null) {
        return Email.fromJson(jsonDecode(entry.value));
      } else {
        throw NotFoundLComposedEmailException();
      }
    }).catchError(_exceptionThrower.throwException);
  }
}

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';

extension TmailServerSettingsExtension on TMailServerSettings {
  TMailServerSettings normalized(Session session, AccountId accountId) {
    if (session.isLanguageReadOnly(accountId)) {
      return TMailServerSettings(
        id: id,
        settings: TMailServerSettingOptions(
          alwaysReadReceipts: settings?.alwaysReadReceipts,
          displaySenderPriority: settings?.displaySenderPriority,
        ),
      );
    }
    return this;
  }
}
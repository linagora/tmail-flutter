
import 'package:server_settings/server_settings/tmail_server_settings.dart';

extension TmailServerSettingsExtension on TMailServerSettingOptions {
  bool get isDisplaySenderPriority => displaySenderPriority ?? true;

  bool get isAlwaysReadReceipts => alwaysReadReceipts ?? false;

  // Prefer new key; fall back to legacy for older BE versions
  bool get isAINeedsActionEnabled => aiLabelCategorizationEnabled ?? aiNeedsActionEnabled ?? false;
}
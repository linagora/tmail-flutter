import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Readers of `MailboxDashBoardController.accountId`, which stays my own account (ADR-0114).
/// A reader of the shown mailbox uses `ActiveAccountReader` instead, so a new reader here
/// must say why it needs my own account.
const _personalAccountReaders = <String, int>{
  // Composer, identities and drafts: moved to the shown account in T-02.4, drafts in T-04.
  'lib/features/composer/presentation/composer_controller.dart': 13,
  'lib/features/composer/presentation/extensions/composer_print_draft_extension.dart': 1,
  'lib/features/composer/presentation/extensions/handle_mobile_auto_save_extension.dart': 3,
  'lib/features/composer/presentation/extensions/setup_email_content_extension.dart': 2,
  'lib/features/composer/presentation/extensions/setup_email_request_read_receipt_flag_extension.dart': 1,
  'lib/features/composer/presentation/extensions/setup_list_identities_extension.dart': 1,
  'lib/features/composer/presentation/manager/web_composer_reload_snapshot_builder.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_composer_restore_on_mobile_extension.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart': 1,
  // Session setup, settings, vacation, identities, composer cache, contact autocomplete,
  // sending queue and notification taps (T-02.3, T-02.4, T-02.5, T-04).
  'lib/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart': 39,
  // Settings, filters, preferences and premium: always my own account.
  'lib/features/mailbox/presentation/base_mailbox_view.dart': 1,
  'lib/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_create_new_rule_filter.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_preferences_setting_extension.dart': 4,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/premium_cta_context_extension.dart': 2,
  'lib/features/manage_account/presentation/menu/manage_account_menu_controller.dart': 1,
  'lib/features/email/presentation/controller/single_email_controller.dart': 1,
  'lib/features/thread_detail/presentation/extension/thread_detail_open_email_address_detail_action.dart': 1,
  'lib/features/thread_detail/presentation/thread_detail_controller.dart': 1,
  // AI Scribe, ecosystem and Drive: my own services.
  'lib/features/composer/presentation/extensions/ai_scribe/handle_ai_scribe_in_composer_extension.dart': 1,
  'lib/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart': 1,
  'lib/features/mailbox_dashboard/presentation/delegates/ecosystem_provider_listener_delegate.dart': 2,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_ai_needs_action_extension.dart': 1,
  // Contact autocomplete and recent searches: my own data.
  'lib/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart': 2,
  'lib/features/mailbox_dashboard/presentation/extensions/cleanup_recent_search_extension.dart': 1,
  'lib/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart': 2,
  'lib/features/search/email/presentation/search_email_controller.dart': 3,
  // Label setting and its WebSocket, bound to my own account until T-02.4 and T-03.
  'lib/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart': 2,
  // Send queue: each mail keeps the account it was written in (T-04).
  'lib/features/sending_queue/presentation/sending_queue_controller.dart': 2,
  // First load of a new dashboard: the trigger of everShownAccount, which then loads the shown account.
  'lib/features/mailbox/presentation/mailbox_controller.dart': 1,
  'lib/features/quotas/presentation/quotas_controller.dart': 1,
};

/// Readers of the "me" sources `ownEmailAddress` and `getOwnEmailAddress*`. T-02.4 moves the
/// ones of the shown mailbox to `ActiveAccount.ownerEmailAddress` (ADR-0114).
const _ownEmailAddressReaders = <String, int>{
  // Definitions.
  'lib/features/base/mixin/own_email_address_mixin.dart': 4,
  'lib/features/delegation/domain/model/active_account.dart': 1,
  'lib/features/home/domain/extensions/session_extensions.dart': 1,
  // Shown mailbox: moved in T-02.4.
  'lib/features/composer/presentation/composer_controller.dart': 1,
  'lib/features/composer/presentation/extensions/composer_print_draft_extension.dart': 1,
  'lib/features/email/presentation/controller/single_email_controller.dart': 3,
  'lib/features/email_previewer/email_previewer_controller.dart': 2,
  'lib/features/mailbox/presentation/base_mailbox_view.dart': 2,
  'lib/features/mailbox/presentation/mailbox_controller.dart': 2,
  'lib/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart': 2,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_preview_attachment_extension.dart': 3,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart': 2,
  'lib/features/mailbox_dashboard/presentation/extensions/premium_cta_context_extension.dart': 2,
  'lib/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart': 5,
  'lib/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart': 3,
  'lib/features/search/email/presentation/search_email_controller.dart': 1,
  'lib/features/search/mailbox/presentation/search_mailbox_controller.dart': 2,
  'lib/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart': 1,
  'lib/features/thread_detail/presentation/thread_detail_controller.dart': 1,
  // Settings: always my own account.
  'lib/features/manage_account/presentation/extensions/handle_profile_setting_action_type_click_extension.dart': 2,
  'lib/features/manage_account/presentation/identities/identities_controller.dart': 3,
  'lib/features/manage_account/presentation/manage_account_dashboard_controller.dart': 2,
  'lib/features/manage_account/presentation/manage_account_dashboard_view.dart': 2,
  'lib/features/manage_account/presentation/menu/settings/settings_first_level_view.dart': 1,
};

typedef SourceCounter = int Function(String source);

const _settingsFolder = 'lib/features/manage_account';

final _lineComment = RegExp(r'^[ \t]*//.*$', multiLine: true);
final _accountIdReceiver = RegExp(r'\b(\w+)\.accountId\b');
final _dashboardName = RegExp('dashboard', caseSensitive: false);
final _settingsDashboardName = RegExp(r'^_?(account|manageAccount)', caseSensitive: false);
final _dashboardOwner = RegExp(r'class MailboxDashBoardController\b|extension \w+ on MailboxDashBoardController\b');
final _dashboardView = RegExp(r'extends (?:BaseMailboxDashBoardView\b|GetWidget<MailboxDashBoardController>)');
final _viewControllerAccountIdRead = RegExp(r'\bcontroller\.accountId\b');
final _foundDashboardAccountIdRead = RegExp(r'<MailboxDashBoardController>\(\)\.accountId\b');
final _ownAccountIdRead = RegExp(r'(?<![\w.])accountId\.value\b|\bthis\.accountId\.value\b');
final _ownEmailAddressRead = RegExp(r'\bownEmailAddress\.value\b|\bgetOwnEmailAddress\w*\(');
final _shownAccountUse = RegExp(r'\b(ActiveAccountReader|ActiveAccountBridge|activeAccountProvider|activeAccountId)\b');

void main() {
  test('every reader of the dashboard accountId is listed with why it needs my own account', _expectListedAccountIdReaders);
  test('every reader of ownEmailAddress and getOwnEmailAddress* is listed', _expectListedOwnEmailAddressReaders);
  test('Settings never reads the shown account', _expectSettingsNeverReadsShownAccount);
}

void _expectListedAccountIdReaders() {
  expect(
    _countPerFile(_countDashboardAccountIdReads),
    _personalAccountReaders,
    reason: 'Read the shown mailbox through ActiveAccountReader. '
        'Add a reader of my own account to the list with the reason it needs it.',
  );
}

void _expectListedOwnEmailAddressReaders() {
  expect(
    _countPerFile((source) => _ownEmailAddressRead.allMatches(source).length),
    _ownEmailAddressReaders,
    reason: 'Use ActiveAccount.ownerEmailAddress for "me" in the shown mailbox.',
  );
}

void _expectSettingsNeverReadsShownAccount() {
  expect(
    _countPerFile((source) => _shownAccountUse.allMatches(source).length, folder: _settingsFolder),
    isEmpty,
    reason: 'Settings reads my own account only (ADR-0114).',
  );
}

int _countDashboardAccountIdReads(String source) {
  final receiverReads = _accountIdReceiver.allMatches(source).where((match) {
    final receiver = match.group(1)!;
    return _dashboardName.hasMatch(receiver) && !_settingsDashboardName.hasMatch(receiver);
  }).length;
  final ownReads = _dashboardOwner.hasMatch(source) ? _ownAccountIdRead.allMatches(source).length : 0;
  final viewReads = _dashboardView.hasMatch(source) ? _viewControllerAccountIdRead.allMatches(source).length : 0;
  return receiverReads + ownReads + viewReads + _foundDashboardAccountIdRead.allMatches(source).length;
}

Map<String, int> _countPerFile(SourceCounter count, {String folder = 'lib'}) {
  final counts = <String, int>{};
  final files = Directory(folder)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'));
  for (final file in files) {
    final found = count(file.readAsStringSync().replaceAll(_lineComment, ''));
    if (found > 0) counts[file.path] = found;
  }
  return counts;
}

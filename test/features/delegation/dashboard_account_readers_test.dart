import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Readers of `MailboxDashBoardController.accountId`, which stays my own account (ADR-0114).
/// A reader of the shown mailbox uses `ActiveAccountReader` instead, so a new reader here
/// must say why it needs my own account. Receivers are matched by name, so an alias of the
/// dashboard escapes the scan: a guard until these readers move to Riverpod.
const _personalAccountReaders = <String, int>{
  // Settings, filters, preferences and premium: always my own account.
  'lib/features/mailbox/presentation/base_mailbox_view.dart': 1,
  'lib/features/mailbox_dashboard/presentation/widgets/navigation_bar/dashboard_navigation_bar.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_create_new_rule_filter.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_preferences_setting_extension.dart': 4,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/premium_cta_context_extension.dart': 2,
  'lib/features/manage_account/presentation/menu/manage_account_menu_controller.dart': 1,
  'lib/features/thread_detail/presentation/thread_detail_controller.dart': 1,
  // AI Scribe, ecosystem and Drive: my own services.
  'lib/features/composer/presentation/extensions/ai_scribe/handle_ai_scribe_in_composer_extension.dart': 1,
  'lib/features/composer/presentation/extensions/setup_email_request_read_receipt_flag_extension.dart': 1,
  'lib/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart': 1,
  'lib/features/mailbox_dashboard/presentation/delegates/ecosystem_provider_listener_delegate.dart': 2,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_ai_needs_action_extension.dart': 1,
  // Recent searches: my own data. Autocomplete bindings: registered once at start, for my own account.
  'lib/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart': 1,
  'lib/features/mailbox_dashboard/presentation/extensions/cleanup_recent_search_extension.dart': 1,
  'lib/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart': 2,
  'lib/features/search/email/presentation/search_email_controller.dart': 2,
  // WebSocket connection account stays mine until T-03; label capability itself reads the shown account.
  'lib/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart': 1,
  // Send queue: each mail keeps the account it was written in (T-04).
  'lib/features/sending_queue/presentation/sending_queue_controller.dart': 2,
};

const _dashboardControllerPath = 'lib/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

/// Readers of my own account inside `MailboxDashBoardController`, per member, so a misplaced
/// one shows up by name.
const _dashboardPersonalAccountReaders = <String, int>{
  // Session setup and logout.
  '_setUpComponentsFromSession': 1,
  '_handleLogOutAndSignInNewAccount': 2,
  // Vacation: a setting of my own account.
  '_getVacationResponse': 2,
  'disableVacationResponder': 2,
  // Identity-cache restore opens Settings on mine only (ADR-0114).
  '_handleIdentityCache': 2,
  // Personal ownEmailAddress is updated from identities only while mine is shown.
  '_handleGetAllIdentitiesSuccess': 1,
  '_handleGetAllIdentitiesFailure': 1,
  // Sending queue: each mail keeps the account it was written in (T-04).
  'getAllSendingEmails': 2,
  '_handleSendEmailSuccess': 2,
  // Contact autocomplete and the contact pickers of the search filter: my own contacts.
  'getContactSuggestion': 2,
  '_setUpMinInputLengthAutocomplete': 2,
  'selectFromSearchFilter': 2,
  'selectToSearchFilter': 2,
  // Notification taps: my own account until T-03.
  '_handleNotificationMessageFromEmailId': 1,
};

/// Readers of the "me" sources `ownEmailAddress` and `getOwnEmailAddress*`. Shown-mailbox
/// "me" uses `ownerEmailAddress` / `ownerEmailAddresses` (ADR-0114 / T-02.5).
const _ownEmailAddressReaders = <String, int>{
  // Definitions.
  'lib/features/base/mixin/own_email_address_mixin.dart': 4,
  'lib/features/delegation/domain/model/active_account.dart': 1,
  'lib/features/home/domain/extensions/session_extensions.dart': 1,
  // Personal display: nav, avatar, profile, premium, Settings, session sync.
  'lib/features/mailbox/presentation/base_mailbox_view.dart': 2,
  'lib/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart': 3,
  'lib/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart': 2,
  'lib/features/mailbox_dashboard/presentation/extensions/premium_cta_context_extension.dart': 2,
  'lib/features/mailbox_dashboard/presentation/widgets/navigation_bar/dashboard_navigation_bar.dart': 2,
  'lib/features/mailbox_dashboard/presentation/widgets/profile_setting/cozy_profile_setting_icon.dart': 2,
  'lib/features/manage_account/presentation/extensions/handle_profile_setting_action_type_click_extension.dart': 2,
  'lib/features/manage_account/presentation/identities/identities_controller.dart': 3,
  'lib/features/manage_account/presentation/manage_account_dashboard_controller.dart': 2,
  'lib/features/manage_account/presentation/manage_account_dashboard_view.dart': 2,
  'lib/features/manage_account/presentation/menu/settings/settings_first_level_view.dart': 1,
  // Session fallback when the shown-mailbox display string is empty.
  'lib/features/composer/presentation/extensions/composer_print_draft_extension.dart': 1,
  'lib/features/email/presentation/controller/single_email_controller.dart': 2,
  'lib/features/email_previewer/email_previewer_controller.dart': 2,
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
final _shownAccountUse = RegExp(r'\b(ActiveAccountReader|ActiveAccountSource|activeAccountProvider|activeAccountId)\b');
final _classMemberStart = RegExp(r'^  [^\s}@)\]]');
final _memberName = RegExp(r'\b(?:get\s+)?(\w+)\s*[(=;{]');

void main() {
  test('every reader of the dashboard accountId is listed with why it needs my own account', _expectListedAccountIdReaders);
  test('every reader inside MailboxDashBoardController is listed per member', _expectListedDashboardMemberReaders);
  test('every reader of ownEmailAddress and getOwnEmailAddress* is listed', _expectListedOwnEmailAddressReaders);
  test('Settings never reads the shown account', _expectSettingsNeverReadsShownAccount);
}

void _expectListedAccountIdReaders() {
  expect(
    _countPerFile(_countDashboardAccountIdReads),
    {
      ..._personalAccountReaders,
      _dashboardControllerPath: _dashboardPersonalAccountReaders.values.reduce((sum, count) => sum + count),
    },
    reason: 'Read the shown mailbox through ActiveAccountReader. '
        'Add a reader of my own account to the list with the reason it needs it.',
  );
}

void _expectListedDashboardMemberReaders() {
  expect(
    _countPerMember(File(_dashboardControllerPath).readAsStringSync().replaceAll(_lineComment, '')),
    _dashboardPersonalAccountReaders,
    reason: 'Read the shown mailbox through activeAccountId. '
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

int _countDashboardReceiverReads(String source) => _accountIdReceiver.allMatches(source).where((match) {
      final receiver = match.group(1)!;
      return _dashboardName.hasMatch(receiver) && !_settingsDashboardName.hasMatch(receiver);
    }).length;

int _countDashboardAccountIdReads(String source) {
  final receiverReads = _countDashboardReceiverReads(source);
  final ownReads = _dashboardOwner.hasMatch(source) ? _ownAccountIdRead.allMatches(source).length : 0;
  final viewReads = _dashboardView.hasMatch(source) ? _viewControllerAccountIdRead.allMatches(source).length : 0;
  return receiverReads + ownReads + viewReads + _foundDashboardAccountIdRead.allMatches(source).length;
}

/// Counts the reads of my own account in each member of a class body indented by two spaces.
Map<String, int> _countPerMember(String source) {
  final counts = <String, int>{};
  var member = '';
  for (final line in source.split('\n')) {
    if (_classMemberStart.hasMatch(line)) {
      member = _memberName.firstMatch(line)?.group(1) ?? line.trim();
    }
    final found = _countDashboardReceiverReads(line) + _ownAccountIdRead.allMatches(line).length;
    if (found > 0) counts.update(member, (count) => count + found, ifAbsent: () => found);
  }
  return counts;
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

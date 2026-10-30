import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Settings entries handed to a view, each hidden while a delegated account is shown (ADR-0114).
/// The dashboard also refuses to open Settings then, so an entry missing here only looks broken.
const _gatedSettingsEntries = <String, int>{
  'lib/features/email/presentation/email_view.dart': 1,
  'lib/features/mailbox/presentation/base_mailbox_view.dart': 1,
  'lib/features/mailbox_dashboard/presentation/mailbox_dashboard_view_web.dart': 1,
  'lib/features/thread/presentation/thread_view.dart': 1,
  'lib/features/thread_detail/presentation/thread_detail_view.dart': 1,
};

/// Avatar menus listing Manage account.
const _gatedProfileMenus = <String, int>{
  'lib/features/mailbox_dashboard/presentation/widgets/navigation_bar/dashboard_navigation_bar.dart': 1,
  'lib/features/mailbox_dashboard/presentation/widgets/profile_setting/cozy_profile_setting_icon.dart': 1,
};

final _lineComment = RegExp(r'^[ \t]*//.*$', multiLine: true);
final _settingsEntry = RegExp(r'\.goTo(?:Settings|VacationSetting)\b');
final _profileMenuList = RegExp(r'\bProfileSettingActionType\.(?:values|shown)\b');
const _gate = 'canOpenSettings';

void main() {
  test('every Settings entry handed to a view is hidden while Settings cannot open', () {
    expect(
      _countLinesPerFile(_settingsEntry),
      _gatedSettingsEntries,
      reason: 'Pass the entry only when canOpenSettings, and list it here.',
    );
  });

  test('every avatar menu lists Manage account only while Settings can open', () {
    expect(
      _countLinesPerFile(_profileMenuList),
      _gatedProfileMenus,
      reason: 'Use ProfileSettingActionType.shown with canOpenSettings, and list the menu here.',
    );
  });
}

/// Lines matching [pattern] per file, failing on one that does not read the gate.
Map<String, int> _countLinesPerFile(RegExp pattern) {
  final counts = <String, int>{};
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'));
  for (final file in files) {
    final lines = file.readAsStringSync().replaceAll(_lineComment, '').split('\n');
    final matching = lines.where(pattern.hasMatch).toList();
    if (matching.isEmpty) continue;
    for (final line in matching) {
      expect(line, contains(_gate), reason: '${file.path} hands a Settings entry without the gate: $line');
    }
    counts[file.path] = matching.length;
  }
  return counts;
}

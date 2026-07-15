import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcuts_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

void main() {
  final appLocalizations = AppLocalizations();

  List<KeyboardShortcut> shortcutsOf(ShortcutCategory category) =>
      KeyboardShortcutsManager.generateKeyboardShortcuts(appLocalizations)
          .where((shortcut) => shortcut.category == category)
          .toList();

  group('KeyboardShortcutsManager::generateKeyboardShortcuts', () {
    test('should generate shortcuts for every category', () {
      final shortcuts =
          KeyboardShortcutsManager.generateKeyboardShortcuts(appLocalizations);

      for (final category in ShortcutCategory.values) {
        expect(
          shortcuts.any((shortcut) => shortcut.category == category),
          isTrue,
          reason: 'Missing shortcuts for $category',
        );
      }
    });

    test('should not produce duplicate rows within any category', () {
      for (final category in ShortcutCategory.values) {
        final rows = shortcutsOf(category);

        expect(
          rows.toSet().length,
          rows.length,
          reason: 'Duplicate shortcut rows found in $category',
        );
      }
    });

    test(
        'should expose a single Delete row in message management category '
        'after removing context distinction', () {
      final deleteRows = shortcutsOf(
        ShortcutCategory.messageManagementAndSelection,
      ).where((shortcut) => shortcut.keys.contains('Delete')).toList();

      expect(deleteRows.length, 1);
    });
  });
}

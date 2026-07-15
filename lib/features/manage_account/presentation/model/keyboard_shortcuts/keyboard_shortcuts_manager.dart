import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class KeyboardShortcutsManager {
  KeyboardShortcutsManager._();

  static List<KeyboardShortcut> generateKeyboardShortcuts(
    AppLocalizations appLocalizations,
  ) {
    return [
      // Navigation & Closing
      KeyboardShortcut(
        label: appLocalizations.closeMailComposer,
        category: ShortcutCategory.navigationAndClosing,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.closeMailDetailView,
        category: ShortcutCategory.navigationAndClosing,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.removeFocusFromSearch,
        category: ShortcutCategory.navigationAndClosing,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.closeModalWindow,
        category: ShortcutCategory.navigationAndClosing,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.openNewMessage,
        category: ShortcutCategory.navigationAndClosing,
        keys: ['N'],
      ),

      // Reading & Replying
      KeyboardShortcut(
        label: appLocalizations.reply,
        category: ShortcutCategory.readingAndReplying,
        keys: ['R'],
      ),
      KeyboardShortcut(
        label: appLocalizations.replyToAll,
        category: ShortcutCategory.readingAndReplying,
        keys: ['Shift', 'R'],
      ),
      KeyboardShortcut(
        label: appLocalizations.forward,
        category: ShortcutCategory.readingAndReplying,
        keys: ['F'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_read,
        category: ShortcutCategory.readingAndReplying,
        keys: ['Q'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_unread,
        category: ShortcutCategory.readingAndReplying,
        keys: ['U'],
      ),

      // Message Management & Selection
      KeyboardShortcut(
        label: appLocalizations.deleteMessage,
        category: ShortcutCategory.messageManagementAndSelection,
        keys: ['Delete'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_read,
        category: ShortcutCategory.messageManagementAndSelection,
        keys: ['Q'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_unread,
        category: ShortcutCategory.messageManagementAndSelection,
        keys: ['U'],
      ),
    ];
  }
}

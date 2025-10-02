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
        context: ShortcutContext.mailComposer,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.removeFocusFromSearch,
        category: ShortcutCategory.navigationAndClosing,
        context: ShortcutContext.focusOnSearch,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.closeModalWindow,
        category: ShortcutCategory.navigationAndClosing,
        context: ShortcutContext.openedModal,
        keys: ['ESC'],
      ),
      KeyboardShortcut(
        label: appLocalizations.openNewMessage,
        category: ShortcutCategory.navigationAndClosing,
        context: ShortcutContext.mailboxList,
        keys: ['N'],
      ),

      // Reading & Replying
      KeyboardShortcut(
        label: appLocalizations.reply,
        category: ShortcutCategory.readingAndReplying,
        context: ShortcutContext.openedMailView,
        keys: ['R'],
      ),
      KeyboardShortcut(
        label: appLocalizations.replyToAll,
        category: ShortcutCategory.readingAndReplying,
        context: ShortcutContext.openedMailView,
        keys: ['Shift', 'R'],
      ),
      KeyboardShortcut(
        label: appLocalizations.forward,
        category: ShortcutCategory.readingAndReplying,
        context: ShortcutContext.openedMailView,
        keys: ['F'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_read,
        category: ShortcutCategory.readingAndReplying,
        context: ShortcutContext.openedMailView,
        keys: ['Q'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_unread,
        category: ShortcutCategory.readingAndReplying,
        context: ShortcutContext.openedMailView,
        keys: ['U'],
      ),

      // Message Management & Selection
      KeyboardShortcut(
        label: appLocalizations.deleteMessage,
        category: ShortcutCategory.messageManagementAndSelection,
        context: ShortcutContext.openedMailView,
        keys: ['Delete'],
      ),
      KeyboardShortcut(
        label: appLocalizations.deleteMessage,
        category: ShortcutCategory.messageManagementAndSelection,
        context: ShortcutContext.mailboxListWithSelectedEmail,
        keys: ['Delete'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_read,
        category: ShortcutCategory.messageManagementAndSelection,
        context: ShortcutContext.mailboxListWithSelectedEmail,
        keys: ['Q'],
      ),
      KeyboardShortcut(
        label: appLocalizations.mark_as_unread,
        category: ShortcutCategory.messageManagementAndSelection,
        context: ShortcutContext.mailboxListWithSelectedEmail,
        keys: ['U'],
      ),
    ];
  }
}

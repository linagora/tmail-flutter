
import 'package:core/presentation/views/shortcut/key_shortcut.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_view_action_shortcut_type.dart';

extension KeyShortcutExtension on KeyShortcut {
  MailViewActionShortcutType? get mailViewActionShortcutType {
    if (matches('r')) {
      return MailViewActionShortcutType.reply;
    } else if (matches('r', shift: true)) {
      return MailViewActionShortcutType.replyAll;
    } else if (matches('f')) {
      return MailViewActionShortcutType.forward;
    } else if (matches('u')) {
      return MailViewActionShortcutType.markAsUnread;
    } else if (matches('n')) {
      return MailViewActionShortcutType.newMessage;
    } else if (matches('backspace') || matches('delete')) {
      return MailViewActionShortcutType.delete;
    }
    return null;
  }
}
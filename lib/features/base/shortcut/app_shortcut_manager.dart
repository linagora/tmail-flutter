import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/base/extensions/logical_key_set_helper.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_view_action_shortcut_type.dart';

class AppShortcutManager {
  static MailViewActionShortcutType? getMailViewActionFromEvent(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    log('AppShortcutManager::getMailViewActionFromEvent: Keys pressed: $keysPressed');
    if (keysPressed.isOnly(LogicalKeyboardKey.keyR)) {
      return MailViewActionShortcutType.reply;
    } else if (keysPressed.isShiftPlus(LogicalKeyboardKey.keyR)) {
      return MailViewActionShortcutType.replyAll;
    } else if (keysPressed.isOnly(LogicalKeyboardKey.keyF)) {
      return MailViewActionShortcutType.forward;
    } else if (keysPressed.isOnly(LogicalKeyboardKey.delete) ||
        keysPressed.isOnly(LogicalKeyboardKey.backspace)) {
      return MailViewActionShortcutType.delete;
    } else if (keysPressed.isOnly(LogicalKeyboardKey.keyN)) {
      return MailViewActionShortcutType.newMessage;
    } else if (keysPressed.isOnly(LogicalKeyboardKey.keyU)) {
      return MailViewActionShortcutType.markAsUnread;
    } else {
      return null;
    }
  }
}

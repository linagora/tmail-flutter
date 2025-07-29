import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/features/base/extensions/logical_key_set_helper.dart';
import 'package:tmail_ui_user/features/base/shortcut/composer/composer_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_list_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_view_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/base/shortcut/search/search_action_shortcut_type.dart';

class AppShortcutManager {
  static const int escapeKeyCode = 27;

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

  static MailListActionShortcutType? getMailListActionFromEvent(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    log('AppShortcutManager::getMailListActionFromEvent: Keys pressed: $keysPressed');
    if (keysPressed.isOnly(LogicalKeyboardKey.delete) ||
        keysPressed.isOnly(LogicalKeyboardKey.backspace)) {
      return MailListActionShortcutType.delete;
    } else if (keysPressed.isOnly(LogicalKeyboardKey.keyN)) {
      return MailListActionShortcutType.newMessage;
    } else if (keysPressed.isOnly(LogicalKeyboardKey.keyQ)) {
      return MailListActionShortcutType.markAsRead;
    }  else if (keysPressed.isOnly(LogicalKeyboardKey.keyU)) {
      return MailListActionShortcutType.markAsUnread;
    } else {
      return null;
    }
  }

  static SearchActionShortcutType? getSearchActionFromEvent(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    log('AppShortcutManager::getSearchActionFromEvent: Keys pressed: $keysPressed');
    if (keysPressed.isOnly(LogicalKeyboardKey.escape)) {
      return SearchActionShortcutType.unFocus;
    } else {
      return null;
    }
  }

  static ComposerActionShortcutType? getComposerActionFromEvent(KeyEvent event) {
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    log('AppShortcutManager::getComposerActionFromEvent: Keys pressed: $keysPressed');
    if (keysPressed.isOnly(LogicalKeyboardKey.escape)) {
      return ComposerActionShortcutType.closeView;
    } else {
      return null;
    }
  }

  static ComposerActionShortcutType? getComposerActionFromKeyCode(int? keyCode) {
    log('AppShortcutManager::getComposerActionFromKeyCode: Keys pressed: $keyCode');
    if (keyCode == escapeKeyCode) {
      return ComposerActionShortcutType.closeView;
    } else {
      return null;
    }
  }
}

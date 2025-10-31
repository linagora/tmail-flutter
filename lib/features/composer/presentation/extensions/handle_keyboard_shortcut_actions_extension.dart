
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:tmail_ui_user/features/base/shortcut/app_shortcut_manager.dart';
import 'package:tmail_ui_user/features/base/shortcut/composer/composer_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleKeyboardShortcutActionsExtension on ComposerController {
  void onKeyDownEditorAction(int? keyCode) {
    log('$runtimeType::onKeyDownEditorAction:🔥keyCode: $keyCode');
    final shortcutType = AppShortcutManager.getComposerActionFromKeyCode(keyCode);
    log('$runtimeType::onKeyDownEditorAction:🔥Shortcut triggered: $shortcutType');
    if (shortcutType == null) return;
    handleComposerShortcutAction(shortcutType);
  }

  void onKeyboardShortcutInit() {
    if (PlatformInfo.isWeb) {
      keyboardShortcutFocusNode = FocusNode();
    }
  }

  void onKeyboardShortcutDispose() {
    if (PlatformInfo.isWeb) {
      keyboardShortcutFocusNode?.dispose();
    }
  }

  void refocusKeyboardShortcutFocus() {
    if (keyboardShortcutFocusNode?.hasFocus == false) {
      keyboardShortcutFocusNode?.requestFocus();
    }
  }

  void onKeyDownEventAction(KeyEvent event) {
    final shortcutType = AppShortcutManager.getComposerActionFromEvent(event);
    log('$runtimeType::onKeyDownEventAction:🔥Shortcut triggered: $shortcutType');
    if (shortcutType == null) return;
    handleComposerShortcutAction(shortcutType);
  }

  void handleComposerShortcutAction(ComposerActionShortcutType shortcutType) {
    log('$runtimeType::handleComposerShortcutAction: 🔥 Shortcut triggered: $shortcutType');
    switch(shortcutType) {
      case ComposerActionShortcutType.closeView:
        if (currentContext == null) return;
        handleClickCloseComposer(currentContext!);
        break;
    }
  }
}
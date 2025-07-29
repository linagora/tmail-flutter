
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:tmail_ui_user/features/base/shortcut/app_shortcut_manager.dart';
import 'package:tmail_ui_user/features/base/shortcut/search/search_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';

extension HandleKeyboardShortcutActionsExtension on SearchController {
  void onKeyboardShortcutInit() {
    if (PlatformInfo.isWeb) {
      keyboardFocusNode = FocusNode();
    }
  }

  void onKeyboardShortcutDispose() {
    if (PlatformInfo.isWeb) {
      keyboardFocusNode?.dispose();
    }
  }

  void clearKeyboardShortcutFocus() {
    if (keyboardFocusNode?.hasFocus == true) {
      keyboardFocusNode?.unfocus();
    }
  }

  void refocusKeyboardShortcutFocus() {
    if (keyboardFocusNode?.hasFocus == false) {
      keyboardFocusNode?.requestFocus();
    }
  }

  void onKeyDownEventAction(KeyEvent event) {
    final shortcutType = AppShortcutManager.getSearchActionFromEvent(event);
    log('$runtimeType::onKeyDownEventAction:🔥Shortcut triggered: $shortcutType');
    if (shortcutType == null) return;
    handleSearchShortcutAction(shortcutType);
  }

  void handleSearchShortcutAction(SearchActionShortcutType shortcutType) {
    log('$runtimeType::handleSearchShortcutAction: 🔥 Shortcut triggered: $shortcutType');
    if (searchFocus.hasFocus) {
      searchFocus.unfocus();
    }
  }
}
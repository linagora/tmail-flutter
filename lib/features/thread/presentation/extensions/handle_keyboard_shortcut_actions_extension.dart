import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/base/shortcut/app_shortcut_manager.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_list_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/mail_searched_list_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/handle_shift_selection_email_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/mail_list_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

extension HandleKeyboardShortcutActionsExtension on ThreadController {
  void onKeyboardShortcutInit() {
    if (PlatformInfo.isWeb) {
      keyboardFocusNode = FocusNode();
      shortcutActionEventController =
          StreamController<MailListShortcutActionViewEvent>();
      shortcutActionEventSubscription = shortcutActionEventController
          ?.stream
          .debounceTime(const Duration(milliseconds: 300))
          .listen(_onShortcutActionViewEvent);
    }
  }

  void _onShortcutActionViewEvent(MailListShortcutActionViewEvent event) {
    pressEmailSelectionAction(event.actionType, event.listPresentationEmail);
  }

  void onKeyboardShortcutDispose() {
    if (PlatformInfo.isWeb) {
      keyboardFocusNode?.dispose();
      shortcutActionEventSubscription?.cancel();
      shortcutActionEventController?.close();
    }
  }

  void clearMailShortcutFocus() {
    if (keyboardFocusNode?.hasFocus == true) {
      keyboardFocusNode?.unfocus();
    }
  }

  void refocusMailShortcutFocus() {
    if (keyboardFocusNode?.hasFocus == false) {
      keyboardFocusNode?.requestFocus();
    }
  }

  void onKeyDownEventAction(KeyEvent event) {
    handleShiftSelectionEmail(event);

    final shortcutType = AppShortcutManager.getMailListActionFromEvent(event);
    log('$runtimeType::onKeyDownEventAction:🔥Shortcut triggered: $shortcutType');
    if (shortcutType == null) return;

    if (searchController.isSearchEmailRunning) {
      handleMailSearchListShortcutAction(shortcutType);
    } else {
      handleMailListShortcutAction(shortcutType);
    }
  }

  void handleMailListShortcutAction(MailListActionShortcutType shortcutType) {
    log('$runtimeType::handleMailListShortcutAction: 🔥 Shortcut triggered: $shortcutType');
    final currentMailbox = selectedMailbox;
    if (currentMailbox == null) return;

    final selectedEmails = listEmailSelected;
    final emailActionType = shortcutType.getEmailActionType(
      selectedEmails: selectedEmails,
      selectedMailbox: currentMailbox,
    );

    if (emailActionType == null) return;

    shortcutActionEventController?.add(
      MailListShortcutActionViewEvent(emailActionType, selectedEmails),
    );
  }

  void handleMailSearchListShortcutAction(MailListActionShortcutType shortcutType) {
    log('$runtimeType::handleMailSearchListShortcutAction: 🔥 Shortcut triggered: $shortcutType');
    final selectedEmails = listEmailSelected;
    final emailActionType = shortcutType.getEmailActionTypeBySearch(
      selectedEmails: selectedEmails,
    );

    if (emailActionType == null) return;

    shortcutActionEventController?.add(
      MailSearchedListShortcutActionViewEvent(emailActionType, selectedEmails),
    );
  }
}
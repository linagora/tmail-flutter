import 'dart:async';

import 'package:core/presentation/views/shortcut/key_shortcut.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tmail_ui_user/features/base/shortcut/app_shortcut_manager.dart';
import 'package:tmail_ui_user/features/base/shortcut/mail/mail_view_action_shortcut_type.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/key_shortcut_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/mail_view_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleMailShortcutActionsExtension on ThreadDetailController {

  void onKeyDownEventAction(KeyEvent event) {
    final shortcutType = AppShortcutManager.getMailViewActionFromEvent(event);
    log('$runtimeType::onKeyDownEventAction:🔥Shortcut triggered: $shortcutType');
    if (shortcutType == null) return;
    handleMailShortcutAction(shortcutType);
  }

  PresentationEmail? get currentExpandedEmail {
    final expandedEmailId = currentExpandedEmailId.value;
    if (expandedEmailId == null) return null;

    final expandedPresentationEmail = emailIdsPresentation[expandedEmailId];
    if (expandedPresentationEmail == null) return null;

    return expandedPresentationEmail;
  }

  void onKeyboardShortcutInit() {
    if (PlatformInfo.isWeb) {
      keyboardShortcutFocusNode = FocusNode();
      shortcutActionEventController =
          StreamController<MailViewShortcutActionViewEvent>();
      shortcutActionEventSubscription = shortcutActionEventController
          ?.stream
          .debounceTime(const Duration(milliseconds: 300))
          .listen(_onShortcutActionViewEvent);
    }
  }

  void _onShortcutActionViewEvent(MailViewShortcutActionViewEvent event) {
    mailboxDashBoardController.dispatchEmailUIAction(
      TriggerMailViewKeyboardShortcutAction(
        event.actionType,
        event.presentationEmail,
      ),
    );
  }

  void onKeyboardShortcutDispose() {
    if (PlatformInfo.isWeb) {
      keyboardShortcutFocusNode?.dispose();
      keyboardShortcutFocusNode = null;
      shortcutActionEventSubscription?.cancel();
      shortcutActionEventController?.close();
    }
  }

  void handleMailShortcutAction(MailViewActionShortcutType shortcutType) {
    log('$runtimeType::handleMailShortcutAction:🔥ShortcutType: $shortcutType');
    final expandedEmail = currentExpandedEmail;

    if (expandedEmail == null) return;

    final emailActionType = shortcutType.getEmailActionType(
      currentEmail: expandedEmail,
      ownerEmailAddress: mailboxDashBoardController.ownEmailAddress.value,
    );
    log('$runtimeType::onKeyDownEventAction:🔥EmailActionType: $emailActionType');
    if (emailActionType == null) return;

    shortcutActionEventController?.add(
      MailViewShortcutActionViewEvent(emailActionType, expandedEmail),
    );
  }

  void clearMailShortcutFocus() {
    if (keyboardShortcutFocusNode?.hasFocus == true) {
      keyboardShortcutFocusNode?.unfocus();
    }
  }

  void refocusMailShortcutFocus() {
    if (keyboardShortcutFocusNode?.hasFocus == false) {
      keyboardShortcutFocusNode?.requestFocus();
    }
  }

  void onIFrameKeyboardShortcutAction(KeyShortcut keyShortcut) {
    log('$runtimeType::onIFrameKeyboardShortcutAction: ${keyShortcut.toString()}');
    final shortcutType = keyShortcut.mailViewActionShortcutType;
    log('$runtimeType::onIFrameKeyboardShortcutAction:🔥MailViewActionShortcutType: $shortcutType');
    if (shortcutType == null) return;
    handleMailShortcutAction(shortcutType);
  }
}
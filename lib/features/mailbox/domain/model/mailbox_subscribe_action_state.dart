import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxSubscribeAction {
  subscribe,
  unSubscribe,
  undo;

  String getToastMessageSuccess(BuildContext context) {
    switch(this) {
      case MailboxSubscribeAction.subscribe:
        return AppLocalizations.of(context).toastMessageShowFolderSuccess;
      case MailboxSubscribeAction.unSubscribe:
        return AppLocalizations.of(context).toastMsgHideFolderSuccess;
      case MailboxSubscribeAction.undo:
        return '';
    }
  }
}
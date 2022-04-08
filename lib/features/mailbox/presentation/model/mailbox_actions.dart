
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxActions {
  create,
  moveEmail,
  delete,
  rename,
}

extension MailboxActionsExtension on MailboxActions {

  String getTitle(BuildContext context) {
    switch(this) {
      case MailboxActions.create:
        return AppLocalizations.of(context).mailbox_location;
      case MailboxActions.moveEmail:
        return AppLocalizations.of(context).move_message;
      default:
        return '';
    }
  }
}
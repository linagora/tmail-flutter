
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxAction {
  create,
  moveEmail,
}

extension MailboxActionExtension on MailboxAction {

  String getTitle(BuildContext context) {
    switch(this) {
      case MailboxAction.create:
        return AppLocalizations.of(context).mailbox_location;
      case MailboxAction.moveEmail:
        return AppLocalizations.of(context).move_to_mailbox;
      default:
        return '';
    }
  }
}
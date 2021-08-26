
import 'package:flutter/cupertino.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension EmailActionTypeExtension on EmailActionType {
  String prefixSubjectComposer(BuildContext context) {
    switch(this) {
      case EmailActionType.reply:
      case EmailActionType.replyAll:
        return AppLocalizations.of(context).prefix_reply_email;
      case EmailActionType.forward:
        return AppLocalizations.of(context).prefix_forward_email;
      default:
        return '';
    }
  }
}
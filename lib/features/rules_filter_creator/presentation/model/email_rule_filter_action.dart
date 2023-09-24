

import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRuleFilterAction {
  moveMessage,
  maskAsSeen,
  startIt,
  rejectIt,
  markAsSpam,
  forwardTo;

  String getTitle(BuildContext context) {
    switch(this) {
      case EmailRuleFilterAction.moveMessage:
        return AppLocalizations.of(context).moveMessage;
      case EmailRuleFilterAction.maskAsSeen:
        return AppLocalizations.of(context).maskAsSeen;
      case EmailRuleFilterAction.startIt:
        return AppLocalizations.of(context).startIt;
      case EmailRuleFilterAction.rejectIt:
        return AppLocalizations.of(context).rejectIt;
      case EmailRuleFilterAction.markAsSpam:
        return AppLocalizations.of(context).markAsSpam;
      case EmailRuleFilterAction.forwardTo:
        return AppLocalizations.of(context).forwardTo;
    }
  }
}
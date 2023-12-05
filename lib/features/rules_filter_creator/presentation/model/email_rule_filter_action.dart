import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRuleFilterAction {
  moveMessage,
  maskAsSeen,
  starIt,
  rejectIt,
  markAsSpam,
  forwardTo;

  String getTitle(BuildContext context) {
    switch(this) {
      case EmailRuleFilterAction.moveMessage:
        return AppLocalizations.of(context).moveMessage;
      case EmailRuleFilterAction.maskAsSeen:
        return AppLocalizations.of(context).maskAsSeen;
      case EmailRuleFilterAction.starIt:
        return AppLocalizations.of(context).starIt;
      case EmailRuleFilterAction.rejectIt:
        return AppLocalizations.of(context).rejectIt;
      case EmailRuleFilterAction.markAsSpam:
        return AppLocalizations.of(context).markAsSpam;
      case EmailRuleFilterAction.forwardTo:
        return AppLocalizations.of(context).forwardTo;
    }
  }

  bool getSupported() {
    return this != EmailRuleFilterAction.forwardTo;
  }
}
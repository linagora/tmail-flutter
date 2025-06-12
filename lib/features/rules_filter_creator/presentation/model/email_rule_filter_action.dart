import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRuleFilterAction {
  moveMessage,
  maskAsSeen,
  starIt,
  rejectIt,
  markAsSpam,
  forwardTo;

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case EmailRuleFilterAction.moveMessage:
        return appLocalizations.moveMessage;
      case EmailRuleFilterAction.maskAsSeen:
        return appLocalizations.maskAsSeen;
      case EmailRuleFilterAction.starIt:
        return appLocalizations.starIt;
      case EmailRuleFilterAction.rejectIt:
        return appLocalizations.rejectIt;
      case EmailRuleFilterAction.markAsSpam:
        return appLocalizations.markAsSpam;
      case EmailRuleFilterAction.forwardTo:
        return appLocalizations.forwardTo;
    }
  }

  bool get isSupported => this != EmailRuleFilterAction.forwardTo;
}
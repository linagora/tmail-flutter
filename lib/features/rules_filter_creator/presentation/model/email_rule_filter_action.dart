import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRuleFilterAction {
  moveMessage,
  labelMessage,
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
      case EmailRuleFilterAction.labelMessage:
        return appLocalizations.labelMessage;
    }
  }

  bool isSupported({
    bool isLabelAvailable = false,
  }) {
    if (isLabelAvailable) {
      return this != EmailRuleFilterAction.forwardTo;
    } else {
      return this != EmailRuleFilterAction.labelMessage &&
          this != EmailRuleFilterAction.forwardTo;
    }
  }

  bool get isForwardTo => this == EmailRuleFilterAction.forwardTo;
}
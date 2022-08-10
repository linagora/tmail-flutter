

import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailRuleFilterAction {
  moveMessage;

  String getTitle(BuildContext context) {
    switch(this) {
      case EmailRuleFilterAction.moveMessage:
        return AppLocalizations.of(context).moveMessage;
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum VacationMessageType {
  plainText,
  htmlTemplate
}

extension VacationMessageTypeExtension on VacationMessageType {

  String getTitle(BuildContext context) {
    switch(this) {
      case VacationMessageType.plainText:
        return AppLocalizations.of(context).plain_text;
      case VacationMessageType.htmlTemplate:
        return AppLocalizations.of(context).html_template;
    }
  }
}
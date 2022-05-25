
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SignatureType {
  plainText,
  htmlTemplate
}

extension SignatureTypeExtension on SignatureType {

  String getTitle(BuildContext context) {
    switch(this) {
      case SignatureType.plainText:
        return AppLocalizations.of(context).plain_text;
      case SignatureType.htmlTemplate:
        return AppLocalizations.of(context).html_template;
    }
  }
}

import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension LocaleExtension on Locale {

  String getLanguageName(BuildContext context) {
    switch(languageCode) {
      case 'fr':
        return AppLocalizations.of(context).languageFrench;
      case 'en':
        return AppLocalizations.of(context).languageEnglish;
      case 'vi':
        return AppLocalizations.of(context).languageVietnamese;
      case 'ru':
        return AppLocalizations.of(context).languageRussian;
      default:
        return '';
    }
  }
}
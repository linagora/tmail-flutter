
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension LocaleExtension on Locale {

  String getLanguageNameByCurrentLocale(BuildContext context) {
    switch(languageCode) {
      case 'fr':
        return AppLocalizations.of(context).languageFrench;
      case 'en':
        return AppLocalizations.of(context).languageEnglish;
      case 'vi':
        return AppLocalizations.of(context).languageVietnamese;
      case 'ru':
        return AppLocalizations.of(context).languageRussian;
      case 'ar':
        return AppLocalizations.of(context).languageArabic;
      case 'it':
        return AppLocalizations.of(context).languageItalian;
      case 'de':
        return AppLocalizations.of(context).languageGerman;
      default:
        return '';
    }
  }

  String getSourceLanguageName() {
    switch(languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';  
      case 'vi':
        return 'Tiếng Việt';
      case 'ru':
        return 'Русский';
      case 'ar':
        return 'عربي';
      case 'it':
        return 'Italiano';
      default:
        return '';
    }
  }
}

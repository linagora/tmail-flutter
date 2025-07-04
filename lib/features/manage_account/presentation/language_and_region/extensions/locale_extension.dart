
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension LocaleExtension on Locale {

  String getLanguageNameByCurrentLocale(AppLocalizations appLocalizations) {
    switch(languageCode) {
      case 'fr':
        return appLocalizations.languageFrench;
      case 'en':
        return appLocalizations.languageEnglish;
      case 'vi':
        return appLocalizations.languageVietnamese;
      case 'ru':
        return appLocalizations.languageRussian;
      case 'ar':
        return appLocalizations.languageArabic;
      case 'it':
        return appLocalizations.languageItalian;
      case 'de':
        return appLocalizations.languageGerman;
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

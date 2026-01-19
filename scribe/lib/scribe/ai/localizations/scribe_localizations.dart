import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiple_localization/multiple_localization.dart';
import 'package:scribe/scribe/ai/l10n/messages_all.dart';

class ScribeLocalizations {
  static ScribeLocalizations of(BuildContext context) {
    return Localizations.of<ScribeLocalizations>(context, ScribeLocalizations)!;
  }

  static Future<ScribeLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
      initializeMessages,
      locale,
      (locale) => ScribeLocalizations(),
      setDefaultLocale: true,
    );
  }

  static const LocalizationsDelegate<ScribeLocalizations> delegate =
      _ScribeLocalizationsDelegate();

  // Menu Categories
  String get categoryCorrectGrammar {
    return Intl.message(
      'Correct',
      name: 'categoryCorrectGrammar',
    );
  }

  String get categoryImprove {
    return Intl.message(
      'Improve',
      name: 'categoryImprove',
    );
  }

  String get categoryChangeTone {
    return Intl.message(
      'Change tone',
      name: 'categoryChangeTone',
    );
  }

  String get categoryTranslate {
    return Intl.message(
      'Translate',
      name: 'categoryTranslate',
    );
  }

  // Menu Actions - Improve
  String get actionMakeShorter {
    return Intl.message(
      'Make it shorter',
      name: 'actionMakeShorter',
    );
  }

  String get actionExpandContext {
    return Intl.message(
      'Expand context',
      name: 'actionExpandContext',
    );
  }

  String get actionEmojify {
    return Intl.message(
      'Emojify',
      name: 'actionEmojify',
    );
  }

  String get actionTransformToBullets {
    return Intl.message(
      'Transform to bullets',
      name: 'actionTransformToBullets',
    );
  }

  // Menu Actions - Change Tone
  String get actionMoreProfessional {
    return Intl.message(
      'More professional',
      name: 'actionMoreProfessional',
    );
  }

  String get actionMoreCasual {
    return Intl.message(
      'More casual',
      name: 'actionMoreCasual',
    );
  }

  String get actionMorePolite {
    return Intl.message(
      'More polite',
      name: 'actionMorePolite',
    );
  }

  // Menu Actions - Translate
  String get languageFrench {
    return Intl.message(
      'French',
      name: 'languageFrench',
    );
  }

  String get languageEnglish {
    return Intl.message(
      'English',
      name: 'languageEnglish',
    );
  }

  String get languageRussian {
    return Intl.message(
      'Russian',
      name: 'languageRussian',
    );
  }

  String get languageVietnamese {
    return Intl.message(
      'Vietnamese',
      name: 'languageVietnamese',
    );
  }

  // Input Bar
  String get customPromptAction {
    return Intl.message(
      'Help me write',
      name: 'customPromptAction',
    );
  }

  // Suggestion Dialog
  String get failedToGenerate {
    return Intl.message(
      'Failed to generate AI response',
      name: 'failedToGenerate',
    );
  }

  String get aiAssistant {
    return Intl.message(
      'AI assistant',
      name: 'aiAssistant',
    );
  }

  String get generatingResponse {
    return Intl.message(
      'Generating response',
      name: 'generatingResponse',
    );
  }

  String get replace {
    return Intl.message(
      'Replace',
      name: 'replace',
    );
  }

  String get insert {
    return Intl.message(
      'Insert',
      name: 'insert',
    );
  }
}

class _ScribeLocalizationsDelegate
    extends LocalizationsDelegate<ScribeLocalizations> {
  const _ScribeLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ru', 'vi'].contains(locale.languageCode);

  @override
  Future<ScribeLocalizations> load(Locale locale) =>
      ScribeLocalizations.load(locale);

  @override
  bool shouldReload(_ScribeLocalizationsDelegate old) => false;
}

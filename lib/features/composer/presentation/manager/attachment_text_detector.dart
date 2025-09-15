import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';

class AttachmentTextDetector {
  const AttachmentTextDetector._();
  // List of keywords by language
  static final Map<String, List<String>> _keywordsByLang = {
    LanguageCodeConstants.english: [
      'attach',
      'attachment',
    ],
    LanguageCodeConstants.french: [
      'pièce jointe',
      'fichier joint',
      'document joint',
      'pj',
      'jointe',
      'joint',
    ],
    LanguageCodeConstants.russian: [
      'прикрепить',
      'приложение',
      'документ',
      'файл',
      'отчёт',
      'вложение',
    ],
    LanguageCodeConstants.vietnamese: [
      'đính kèm',
      'tài liệu',
      'tệp',
      'báo cáo',
      'file',
      'attach',
      'attachment',
    ],
    LanguageCodeConstants.arabic: [
      "مرفق",
      "مستند",
      "ملف",
      "تقرير",
      "ملف",
      "إرفاق",
    ],
  };

  /// Detect if the text contains keywords suggesting there is an attachment.
  /// [lang] is the language code (`en`, `fr`, `ru`, `vi`, `ar`, ...).
  static bool containsAttachmentKeyword(String text, {required String lang}) {
    final lowerText = text.toLowerCase();
    final keywords = _keywordsByLang[lang.toLowerCase()];
    if (keywords == null) return false;

    return keywords.any((k) => lowerText.contains(k.toLowerCase()));
  }

  /// Returns a list of matched keywords (if any) for the specified language
  static List<String> matchedKeywords(String text, {required String lang}) {
    final lowerText = text.toLowerCase();
    final keywords = _keywordsByLang[lang.toLowerCase()];
    if (keywords == null) return [];

    return keywords
        .where((k) => lowerText.contains(k.toLowerCase()))
        .toList();
  }

  /// Detect if text contains keyword in any language
  static bool containsAnyAttachmentKeyword(String text) {
    final lowerText = text.toLowerCase();
    for (final keywords in _keywordsByLang.values) {
      if (keywords.any((k) => lowerText.contains(k.toLowerCase()))) {
        return true;
      }
    }
    return false;
  }

  /// Returns a map of languages with a list of matched keywords
  static Map<String, List<String>> matchedKeywordsAll(String text) {
    final result = <String, List<String>>{};
    final lowerText = text.toLowerCase();

    _keywordsByLang.forEach((lang, keywords) {
      final matches =
      keywords.where((k) => lowerText.contains(k.toLowerCase())).toList();
      if (matches.isNotEmpty) {
        result[lang] = matches;
      }
    });

    return result;
  }

  /// Returns a list of matching keywords but removes duplicates
  static List<String> matchedKeywordsUnique(String text) {
    final lowerText = text.toLowerCase();
    final result = <String>{};

    _keywordsByLang.forEach((_, keywords) {
      for (final k in keywords) {
        if (lowerText.contains(k.toLowerCase())) {
          result.add(k);
        }
      }
    });

    return result.toList();
  }
}

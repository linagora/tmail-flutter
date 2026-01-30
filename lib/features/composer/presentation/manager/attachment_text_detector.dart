import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';

class AttachmentTextDetector {
  const AttachmentTextDetector._();
  // List of keywords by language
  static final Map<String, List<String>> _keywordsByLang = {
    LanguageCodeConstants.english: [
      'attach',
      'attachment',
      'attachments',
      'attached',
      'file',
      'files',
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

  // Store a single combined RegExp pattern
  static RegExp? _combinedRegExp;

  /// Initializes a single optimized RegExp that contains all keywords.
  static void _initializeRegExp() {
    if (_combinedRegExp != null) return;

    // Flatten all keywords from all languages into a single list
    final allKeywords = _keywordsByLang.values.expand((list) => list).toSet().toList();

    // Sort keywords by length descending (longest first).
    allKeywords.sort((a, b) => b.length.compareTo(a.length));

    // Create a pattern like: (attachment|attach|file|files)(?![\p{L}])
    // Join all keywords with OR operator (|)
    final patternString = allKeywords.map(RegExp.escape).join('|');

    _combinedRegExp = RegExp(
      '($patternString)(?![\\p{L}])',
      unicode: true,
      caseSensitive: false, // Let Regex handle case-insensitivity
    );
  }

  /// Detects unique keywords in the provided text based on predefined language lists.
  static List<String> matchedKeywordsUnique(String text) {
    if (text.isEmpty) return [];

    // Ensure RegExp are initialized
    _initializeRegExp();

    final matches = _combinedRegExp!.allMatches(text);
    final result = <String>{};

    for (final match in matches) {
      // match.group(0) returns the actual text found (e.g., "FILE", "File").
      // We convert it to lowercase to normalize the result list.
      if (match.group(0) != null) {
        result.add(match.group(0)!.toLowerCase());
      }
    }

    return result.toList();
  }
}

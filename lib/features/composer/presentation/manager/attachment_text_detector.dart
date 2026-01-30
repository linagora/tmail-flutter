import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/detection_params.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/exclude_list_filter.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/keyword_filter.dart';
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
      "إرفاق",
    ],
  };

  /// Cached RegExp Pattern for the default case (when no include list is provided).
  static String? _cachedDefaultPattern;
  /// Threshold to switch from Sync to Async execution.
  ///
  /// Value: 20,000 characters (approx. 4-5 pages of text).
  ///
  /// Technical Rationale:
  /// 1. Frame Budget (16ms): To maintain 60fps, operations on the UI thread must stay under 16ms.
  /// 2. Isolate Overhead: `compute` takes about 2-4ms just to copy data and start the thread.
  /// 3. Real-world Benchmark:
  ///    - For < 20k chars, Sync execution is usually faster (< 10ms) than the Async overhead.
  ///    - For > 20k chars, Regex processing might exceed 16ms on low-end devices, causing jank.
  ///
  /// -> Below 20k: Run Sync (Instant response).
  /// -> Above 20k: Run Async (Safety for UI).
  static const int _kAsyncExecutionThreshold = 20000;

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

  /// Builds the Regex pattern.
  /// Merges [defaultKeywords] with [includeList] to create the search scope.
  static String _generatePatternString(List<String> additionalKeywords) {
    // 1. Get all default keywords
    final defaultKeywords = _keywordsByLang.values.expand((l) => l).toList();

    // 2. Merge with Include List (Add user-defined keywords)
    final allKeywords = {...defaultKeywords, ...additionalKeywords}.toList();

    // 3. Sort by length descending.
    // Crucial to match "attachment" (long) before "attach" (short).
    allKeywords.sort((a, b) => b.length.compareTo(a.length));

    // 4. Create Pattern: (keyword1|keyword2)(?![\p{L}])
    // (?![\p{L}]) ensures we don't match substrings inside other words (e.g., "filetage").
    final pattern = allKeywords.map(RegExp.escape).join('|');

    // (?<![\p{L}]) ensures no letter precedes the keyword
    // (?![\p{L}]) ensures no letter follows the keyword
    return '(?<![\\p{L}])($pattern)(?![\\p{L}])';
  }

  static String _getPattern(List<String> includeList) {
    if (includeList.isNotEmpty) {
      return _generatePatternString(includeList);
    }

    _cachedDefaultPattern ??= _generatePatternString([]);
    return _cachedDefaultPattern!;
  }

  /// The core logic function.
  /// 1. Builds/Retrieves the Regex.
  /// 2. Scans the text.
  /// 3. Filters results using Exclude List.
  static List<String> _processInIsolate(DetectionParams params) {
    final text = params.text;
    if (text.isEmpty) return [];

    final regex = RegExp(
      params.regexPattern,
      unicode: true,
      caseSensitive: false,
    );

    final matches = regex.allMatches(text);
    final result = <String>{};

    for (final match in matches) {
      final keyword = match.group(0)!.toLowerCase();

      // Check if the found keyword should be excluded based on context.
      bool isAccepted = true;
      for (final filter in params.filters) {
        if (!filter.isValid(text, match)) {
          isAccepted = false;
          break;
        }
      }

      if (isAccepted) {
        result.add(keyword);
      }
    }

    return result.toList();
  }

  /// Detects keywords in the text.
  ///
  /// [includeList]: Adds NEW keywords to the search (e.g., 'invoice').
  /// [excludeList]: BLOCKS specific tokens from results (e.g., 'invoice-draft').
  /// [forceSync]: If true, forces execution on the UI thread (for testing).
  static Future<List<String>> matchedKeywordsUnique(
    String text, {
    List<String> includeList = const [],
    List<String> excludeList = const [],
    bool forceSync = false,
  }) async {
    // Prepare filters (Exclude List)
    final filters = <KeywordFilter>[];
    if (excludeList.isNotEmpty) {
      filters.add(ExcludeListFilter(excludeList));
    }

    final patternString = _getPattern(includeList);

    final params = DetectionParams(
      text: text,
      regexPattern: patternString,
      filters: filters,
    );

    // Decision: Run Sync (fast) or Async (safe)
    if (forceSync || text.length < _kAsyncExecutionThreshold) {
      return _processInIsolate(params);
    } else {
      return await compute(_processInIsolate, params);
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/detection_params.dart';
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
      "ملف",
      "إرفاق",
    ],
  };

  static RegExp? _combinedRegExp;
  /// SYNC/ASYNC EXECUTION THRESHOLD
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

  /// Initializes the single optimized RegExp pattern.
  static void _initializeRegExp() {
    if (_combinedRegExp != null) return;

    final allKeywords =
        _keywordsByLang.values.expand((l) => l).toSet().toList();

    // Sort by length descending (Longest first).
    // Crucial to ensure "attachment" is matched before "attach".
    allKeywords.sort((a, b) => b.length.compareTo(a.length));

    // LOGIC:
    // 1. RegExp.escape: Neutralizes special characters.
    // 2. No Nested Quantifiers: Prevents catastrophic backtracking.
    // 3. Linear Scan: Uses logical OR (|) for a single-pass scan.
    final pattern = allKeywords.map(RegExp.escape).join('|');

    // Pattern: (keyword1|keyword2)(?![\p{L}])
    // (?![\p{L}]): Negative lookahead to ensure the next char is NOT a letter.
    // Allows: numbers (file123), punctuation (file.), spaces (file ).
    // Rejects: letter extensions (filetage).
    _combinedRegExp = RegExp(
      '($pattern)(?![\\p{L}])',
      unicode: true,
      caseSensitive: false,
    );
  }

  static List<String> _processMatchedKeywordsInIsolate(DetectionParams params) {
    // Re-initialize RegExp (Isolates do not share static memory with the main app)
    _initializeRegExp();

    final text = params.text;
    final filters = params.filters;

    if (text.isEmpty) return [];

    final matches = _combinedRegExp!.allMatches(text);
    final result = <String>{};

    for (final match in matches) {
      final keyword = match.group(0)!.toLowerCase();

      // Apply Filter Pipeline
      bool isAccepted = true;
      for (final filter in filters) {
        if (!filter.isValid(text, match)) {
          isAccepted = false;
          break; // Stop checking other filters to save CPU
        }
      }

      if (isAccepted) {
        result.add(keyword);
      }
    }

    return result.toList();
  }

  /// Smart keyword detection (Hybrid Sync/Async).
  /// Automatically decides whether to run on the UI Thread or a Background Thread.
  /// [forceSync]: If true, it will be MANDATORY to run on the UI Thread (ignoring the threshold).
  /// Use this parameter for unit tests to benchmark the algorithm more accurately.
  static Future<List<String>> matchedKeywordsUnique(
    String text, {
    List<KeywordFilter> filters = const [],
    bool forceSync = false,
  }) async {
    // If text is short, run Synchronously to avoid Isolate overhead cost.
    if (forceSync || text.length < _kAsyncExecutionThreshold) {
      return _processMatchedKeywordsInIsolate(
        DetectionParams(text: text, filters: filters),
      );
    } else { // If text is long, use `compute` to offload to an Isolate, preventing UI freeze.
      return await compute(
        _processMatchedKeywordsInIsolate,
        DetectionParams(text: text, filters: filters),
      );
    }
  }
}

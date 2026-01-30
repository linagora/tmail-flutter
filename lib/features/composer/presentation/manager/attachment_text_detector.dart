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
  /// Cached RegExp Pattern for the case when a custom include list is provided.
  static List<String>? _cachedIncludeList;
  static String? _cachedIncludePattern;
  /// Threshold to switch from Sync to Async execution on native platforms.
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
  /// -> Above 20k: Run Async via `compute` (offloads to a separate Isolate on native).
  ///
  /// **Web limitation:** Flutter Web does not support true Dart isolates. On web, `compute()`
  /// runs on the same main thread, so the async branch does NOT provide UI isolation.
  /// Long drafts (> 20k chars) may still block the event loop on web. A proper web
  /// strategy (e.g., Service Worker or chunked async processing) is not yet implemented.
  static const int _kAsyncExecutionThreshold = 20000;

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
    if (includeList.isEmpty) {
      _cachedDefaultPattern ??= _generatePatternString([]);
      return _cachedDefaultPattern!;
    }

    final cached = _cachedIncludeList;
    if (cached != null &&
        cached.length == includeList.length &&
        cached.every(includeList.contains)) {
      return _cachedIncludePattern!;
    }

    _cachedIncludeList = List.unmodifiable(includeList);
    _cachedIncludePattern = _generatePatternString(includeList);
    return _cachedIncludePattern!;
  }

  static bool _passesAllFilters(
      String text, Match match, List<KeywordFilter> filters) {
    return filters.every((filter) => filter.isValid(text, match));
  }

  /// The core logic function.
  /// 1. Builds/Retrieves the Regex.
  /// 2. Scans the text.
  /// 3. Filters results using Exclude List.
  /// Can be executed on the main thread (sync path) or inside an Isolate (async path).
  static List<String> _detectKeywords(DetectionParams params) {
    final text = params.text;
    if (text.isEmpty) return [];

    final regex = RegExp(
      params.regexPattern,
      unicode: true,
      caseSensitive: false,
    );

    return regex
        .allMatches(text)
        .where((match) => _passesAllFilters(text, match, params.filters))
        .map((match) => match.group(0)!.toLowerCase())
        .toSet()
        .toList();
  }

  /// Clears all cached regex patterns.
  /// Call this when the keyword configuration changes (e.g., on logout or config reload).
  static void clearPatternCache() {
    _cachedDefaultPattern = null;
    _cachedIncludeList = null;
    _cachedIncludePattern = null;
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

    // On native: below threshold → sync (faster), above → offload to Isolate via compute().
    // On web: compute() does not create a real Isolate; both paths run on the main thread.
    if (forceSync || text.length < _kAsyncExecutionThreshold) {
      return _detectKeywords(params);
    } else {
      return await compute(_detectKeywords, params);
    }
  }
}

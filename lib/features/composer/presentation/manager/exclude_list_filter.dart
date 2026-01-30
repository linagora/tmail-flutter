import 'package:tmail_ui_user/features/composer/presentation/manager/keyword_filter.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/token_extraction_mixin.dart';

/// Filter that rejects keywords found in a specific blocklist (Exclude List).
class ExcludeListFilter with TokenExtractionMixin implements KeywordFilter {
  final Set<String> _excludes;

  ExcludeListFilter(List<String> rawExcludes)
      : _excludes = rawExcludes.map((e) => e.toLowerCase()).toSet();

  @override
  bool isValid(String fullText, Match match) {
    if (_excludes.isEmpty) return true;

    // Get the full word context (e.g., "file-246")
    final token = getSurroundingToken(fullText, match.start, match.end);
    final lowerToken = token.toLowerCase();

    // Check 1: Exact match block
    if (_excludes.contains(lowerToken)) return false;

    // Check 2: Block even if it has trailing punctuation (e.g., "file-246.")
    final cleanToken = lowerToken.replaceAll(RegExp(r'[^\w\s]+$'), '');
    if (_excludes.contains(cleanToken)) return false;

    return true;
  }
}

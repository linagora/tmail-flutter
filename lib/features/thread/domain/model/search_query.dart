
import 'package:equatable/equatable.dart';

class SearchQuery with EquatableMixin {
  static final _tokenPattern = RegExp(r'"([^"]+)"|(\S+)');

  final String value;

  SearchQuery(this.value);

  factory SearchQuery.initial() {
    return SearchQuery('');
  }

  /// Splits the query into tokens for multi-keyword AND search.
  ///
  /// - Quoted phrases like `"portal access"` are kept as a single token.
  /// - Unquoted words are split by whitespace.
  ///
  /// Examples:
  /// - `"portal access"` → `["portal", "access"]`
  /// - `'"portal access"'` → `["portal access"]`
  /// - `'"portal access" denied'` → `["portal access", "denied"]`
  List<String> toTokens() {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return [];

    final tokens = <String>[];
    for (final match in _tokenPattern.allMatches(trimmed)) {
      tokens.add(match.group(1) ?? match.group(2)!);
    }
    return tokens;
  }

  @override
  List<Object?> get props => [value];
}
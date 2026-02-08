
import 'package:equatable/equatable.dart';

class SearchQuery with EquatableMixin {
  final String value;

  SearchQuery(this.value);

  factory SearchQuery.initial() {
    return SearchQuery('');
  }

  /// Splits the query into individual word tokens for multi-keyword AND search.
  ///
  /// Quotes are stripped and all words are split by whitespace. Stalwart's
  /// default FTS backend does not support exact phrase matching — it tokenizes
  /// multi-word text values internally and matches with OR logic. Splitting
  /// into individual AND-combined tokens gives accurate results regardless
  /// of server FTS implementation.
  ///
  /// Examples:
  /// - `'portal access'`          → `["portal", "access"]`
  /// - `'"portal access"'`        → `["portal", "access"]`
  /// - `'"portal access" denied'` → `["portal", "access", "denied"]`
  List<String> toTokens() {
    final stripped = value.replaceAll('"', '').trim();
    if (stripped.isEmpty) return [];
    return stripped.split(RegExp(r'\s+'));
  }

  @override
  List<Object?> get props => [value];
}

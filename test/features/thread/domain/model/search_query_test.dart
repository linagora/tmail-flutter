import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

void main() {
  group('SearchQuery::toTokens', () {
    test('SHOULD return empty list WHEN query is empty', () {
      expect(SearchQuery('').toTokens(), isEmpty);
      expect(SearchQuery('   ').toTokens(), isEmpty);
    });

    test('SHOULD return single token WHEN query is one word', () {
      expect(SearchQuery('portal').toTokens(), equals(['portal']));
    });

    test('SHOULD split into separate tokens WHEN query has multiple words', () {
      expect(
        SearchQuery('portal access').toTokens(),
        equals(['portal', 'access']),
      );
    });

    test('SHOULD split three words into three tokens', () {
      expect(
        SearchQuery('portal access denied').toTokens(),
        equals(['portal', 'access', 'denied']),
      );
    });

    test('SHOULD keep quoted phrase as single token', () {
      expect(
        SearchQuery('"portal access"').toTokens(),
        equals(['portal access']),
      );
    });

    test('SHOULD handle mix of quoted phrase and bare words', () {
      expect(
        SearchQuery('"portal access" denied').toTokens(),
        equals(['portal access', 'denied']),
      );
    });

    test('SHOULD handle multiple quoted phrases', () {
      expect(
        SearchQuery('"portal access" "user login"').toTokens(),
        equals(['portal access', 'user login']),
      );
    });

    test('SHOULD handle bare word before quoted phrase', () {
      expect(
        SearchQuery('error "portal access"').toTokens(),
        equals(['error', 'portal access']),
      );
    });

    test('SHOULD trim leading and trailing whitespace', () {
      expect(
        SearchQuery('  portal access  ').toTokens(),
        equals(['portal', 'access']),
      );
    });
  });
}

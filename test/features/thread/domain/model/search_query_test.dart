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

    test('SHOULD split quoted phrase into individual words', () {
      expect(
        SearchQuery('"portal access"').toTokens(),
        equals(['portal', 'access']),
      );
    });

    test('SHOULD split quoted phrase and bare words into individual tokens', () {
      expect(
        SearchQuery('"portal access" denied').toTokens(),
        equals(['portal', 'access', 'denied']),
      );
    });

    test('SHOULD split multiple quoted phrases into individual words', () {
      expect(
        SearchQuery('"portal access" "user login"').toTokens(),
        equals(['portal', 'access', 'user', 'login']),
      );
    });

    test('SHOULD split bare word and quoted phrase into individual tokens', () {
      expect(
        SearchQuery('error "portal access"').toTokens(),
        equals(['error', 'portal', 'access']),
      );
    });

    test('SHOULD return empty list WHEN query is only quotes', () {
      expect(SearchQuery('""').toTokens(), isEmpty);
    });

    test('SHOULD trim leading and trailing whitespace', () {
      expect(
        SearchQuery('  portal access  ').toTokens(),
        equals(['portal', 'access']),
      );
    });
  });
}

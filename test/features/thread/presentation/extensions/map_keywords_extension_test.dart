import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/map_keywords_extension.dart';

void main() {
  group('MapKeywordsExtension - withKeyword()', () {
    test('adds keyword to empty map', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier("\$seen");

      final result = map.withKeyword(keyword);

      expect(result.length, 1);
      expect(result[keyword], true);

      // Ensure original map unchanged
      expect(map.containsKey(keyword), false);
    });

    test('adds keyword to non-empty map', () {
      final map = {
        KeyWordIdentifier("\$flagged"): true,
      };
      final keyword = KeyWordIdentifier("\$seen");

      final result = map.withKeyword(keyword);

      expect(result.length, 2);
      expect(result[keyword], true);
    });

    test('overwrites existing keyword value to true', () {
      final keyword = KeyWordIdentifier("\$seen");

      final map = {
        keyword: false,
      };

      final result = map.withKeyword(keyword);

      expect(result.length, 1);
      expect(result[keyword], true);
      expect(map[keyword], false); // original map not mutated
    });

    test('does not mutate original map', () {
      final keyword = KeyWordIdentifier("\$flagged");
      final map = {
        keyword: false,
      };

      final result = map.withKeyword(keyword);

      expect(result[keyword], true);
      expect(map[keyword], false);
    });
  });

  group('MapKeywordsExtension - withoutKeyword()', () {
    test('removes existing keyword', () {
      final keyword = KeyWordIdentifier("\$seen");

      final map = {
        keyword: true,
        KeyWordIdentifier("\$flagged"): false,
      };

      final result = map.withoutKeyword(keyword);

      expect(result.containsKey(keyword), false);
      expect(result.length, 1);
    });

    test('removing non-existing keyword keeps map unchanged', () {
      final map = {
        KeyWordIdentifier("\$flagged"): true,
      };
      final keyword = KeyWordIdentifier("\$seen");

      final result = map.withoutKeyword(keyword);

      expect(result.length, 1);
      expect(result, map); // equal content
      expect(identical(result, map), false); // but not the same instance
    });

    test('remove keyword from empty map returns empty map', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier("\$junk");

      final result = map.withoutKeyword(keyword);

      expect(result.isEmpty, true);
    });

    test('does not mutate original map', () {
      final keyword = KeyWordIdentifier("\$seen");

      final map = {
        keyword: true,
      };

      final result = map.withoutKeyword(keyword);

      expect(result.containsKey(keyword), false);
      expect(map.containsKey(keyword), true); // original not mutated
    });
  });

  group('MapKeywordsExtension – nullable receiver', () {
    final keyword = KeyWordIdentifier.emailSeen;

    test(
      'null.withKeyword(x) returns new map containing x:true',
      () {
        Map<KeyWordIdentifier, bool>? keywords;

        final result = keywords.withKeyword(keyword);

        expect(result, isNotNull);
        expect(result.length, 1);
        expect(result[keyword], true);
      },
    );

    test(
      'null.withoutKeyword(x) returns empty map (no crash)',
      () {
        Map<KeyWordIdentifier, bool>? keywords;

        final result = keywords.withoutKeyword(keyword);

        expect(result, isNotNull);
        expect(result.isEmpty, true);
      },
    );

    test(
      'null.withoutKeyword(x) is idempotent',
      () {
        Map<KeyWordIdentifier, bool>? keywords;

        final result1 = keywords.withoutKeyword(keyword);
        final result2 = result1.withoutKeyword(keyword);

        expect(result2.isEmpty, true);
      },
    );

    test(
      'null.withKeyword(x) followed by withoutKeyword(x) '
      'returns empty map',
      () {
        Map<KeyWordIdentifier, bool>? keywords;

        final result = keywords.withKeyword(keyword).withoutKeyword(keyword);

        expect(result.isEmpty, true);
      },
    );
  });
}

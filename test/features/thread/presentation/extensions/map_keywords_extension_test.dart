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
      final map = {
        KeyWordIdentifier("\$flagged"): false,
      };
      final keyword = KeyWordIdentifier("\$flagged");

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

  group('MapKeywordsExtension - addKeyword()', () {
    test('adds keyword to empty map', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier('\$seen');

      map.addKeyword(keyword);

      expect(map.length, 1);
      expect(map[keyword], true);
    });

    test('adds keyword to non-empty map', () {
      final map = {
        KeyWordIdentifier('\$flagged'): true,
      };
      final keyword = KeyWordIdentifier('\$seen');

      map.addKeyword(keyword);

      expect(map.length, 2);
      expect(map[keyword], true);
    });

    test('overwrites existing keyword value to true', () {
      final keyword = KeyWordIdentifier('\$seen');

      final map = {
        keyword: false,
      };

      map.addKeyword(keyword);

      expect(map.length, 1);
      expect(map[keyword], true);
    });

    test('does not throw when map is null', () {
      Map<KeyWordIdentifier, bool>? map;
      final keyword = KeyWordIdentifier('\$seen');

      expect(() => map.addKeyword(keyword), returnsNormally);
    });

    test('calling addKeyword on null map has no side effects', () {
      Map<KeyWordIdentifier, bool>? map;
      final keyword = KeyWordIdentifier('\$seen');

      map.addKeyword(keyword);

      expect(map, isNull);
    });

    test('mutates the same map instance', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier('\$seen');

      final originalIdentity = identityHashCode(map);

      map.addKeyword(keyword);

      expect(identityHashCode(map), originalIdentity);
      expect(map[keyword], true);
    });
  });

  group('MapKeywordsExtension - removeKeyword()', () {
    test('removes existing keyword from map', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        keyword: true,
        KeyWordIdentifier('\$flagged'): true,
      };

      map.removeKeyword(keyword);

      expect(map.length, 1);
      expect(map.containsKey(keyword), false);
    });

    test('removes keyword even if its value is false', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        keyword: false,
      };

      map.removeKeyword(keyword);

      expect(map.isEmpty, true);
    });

    test('does nothing when keyword does not exist', () {
      final map = {
        KeyWordIdentifier('\$flagged'): true,
      };
      final keyword = KeyWordIdentifier('\$seen');

      map.removeKeyword(keyword);

      expect(map.length, 1);
      expect(map.values.first, true);
    });

    test('does not throw when map is empty', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier('\$seen');

      expect(() => map.removeKeyword(keyword), returnsNormally);
      expect(map.isEmpty, true);
    });

    test('does not throw when map is null', () {
      Map<KeyWordIdentifier, bool>? map;
      final keyword = KeyWordIdentifier('\$seen');

      expect(() => map.removeKeyword(keyword), returnsNormally);
    });

    test('calling removeKeyword on null map has no side effects', () {
      Map<KeyWordIdentifier, bool>? map;
      final keyword = KeyWordIdentifier('\$seen');

      map.removeKeyword(keyword);

      expect(map, isNull);
    });

    test('mutates the same map instance', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        keyword: true,
      };

      final originalIdentity = identityHashCode(map);

      map.removeKeyword(keyword);

      expect(identityHashCode(map), originalIdentity);
      expect(map.isEmpty, true);
    });
  });

  group('MapKeywordsExtension - toggleKeyword()', () {
    test('adds keyword when remove is false on empty map', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = <KeyWordIdentifier, bool>{};

      map.toggleKeyword(keyword, false);

      expect(map.length, 1);
      expect(map[keyword], true);
    });

    test('adds keyword when remove is false on non-empty map', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        KeyWordIdentifier('\$flagged'): true,
      };

      map.toggleKeyword(keyword, false);

      expect(map.length, 2);
      expect(map[keyword], true);
    });

    test('overwrites existing keyword value to true when remove is false', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        keyword: false,
      };

      map.toggleKeyword(keyword, false);

      expect(map.length, 1);
      expect(map[keyword], true);
    });

    test('removes keyword when remove is true', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        keyword: true,
        KeyWordIdentifier('\$flagged'): true,
      };

      map.toggleKeyword(keyword, true);

      expect(map.length, 1);
      expect(map.containsKey(keyword), false);
    });

    test('does nothing when remove is true and keyword does not exist', () {
      final map = {
        KeyWordIdentifier('\$flagged'): true,
      };
      final keyword = KeyWordIdentifier('\$seen');

      map.toggleKeyword(keyword, true);

      expect(map.length, 1);
      expect(map.values.first, true);
    });

    test('does not throw when map is empty and remove is true', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier('\$seen');

      expect(() => map.toggleKeyword(keyword, true), returnsNormally);
      expect(map.isEmpty, true);
    });

    test('adds keyword when map is empty and remove is false', () {
      final map = <KeyWordIdentifier, bool>{};
      final keyword = KeyWordIdentifier('\$seen');

      expect(() => map.toggleKeyword(keyword, false), returnsNormally);
      expect(map.length, 1);
      expect(map[keyword], true);
    });

    test('does not throw when map is null', () {
      Map<KeyWordIdentifier, bool>? map;
      final keyword = KeyWordIdentifier('\$seen');

      expect(() => map.toggleKeyword(keyword, true), returnsNormally);
      expect(() => map.toggleKeyword(keyword, false), returnsNormally);
    });

    test('calling toggleKeyword on null map has no side effects', () {
      Map<KeyWordIdentifier, bool>? map;
      final keyword = KeyWordIdentifier('\$seen');

      map.toggleKeyword(keyword, false);
      map.toggleKeyword(keyword, true);

      expect(map, isNull);
    });

    test('mutates the same map instance', () {
      final keyword = KeyWordIdentifier('\$seen');
      final map = {
        keyword: true,
      };

      final originalIdentity = identityHashCode(map);

      map.toggleKeyword(keyword, true);

      expect(identityHashCode(map), originalIdentity);
      expect(map.isEmpty, true);
    });
  });
}

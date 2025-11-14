import 'package:core/utils/web_link_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebLinkGenerator', () {
    test('should generate correct link for flat subdomain', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'alice.example.app',
        searchParams: [
          ['sharecode', 'sharingIsCaring'],
          ['username', 'alice'],
        ],
        pathname: 'public',
        hash: '/n/4',
        slug: 'notes',
      );

      expect(
        result,
        'https://alice-notes.example.app/public?sharecode=sharingIsCaring&username=alice#/n/4',
      );
    });

    test('should prepend slash to path and hash if missing', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'bob.example.tools',
        pathname: 'files',
        hash: 'folder/123',
        slug: 'drive',
      );

      expect(result, 'https://bob-drive.example.tools/files#/folder/123');
    });

    test('should work with no search params', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'charlie.domain.com',
        slug: 'settings',
      );

      expect(result, 'https://charlie-settings.domain.com/');
    });

    test('should throw when workplaceFqdn is empty', () {
      expect(
        () => WebLinkGenerator.generateWebLink(
          workplaceFqdn: '',
          slug: 'notes',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when workplaceFqdn only contains TLD', () {
      expect(
        () => WebLinkGenerator.generateWebLink(
          workplaceFqdn: 'com',
          slug: 'notes',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when workplaceFqdn has no dot', () {
      expect(
        () => WebLinkGenerator.generateWebLink(
          workplaceFqdn: 'localhost',
          slug: 'notes',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle malformed FQDN gracefully (multiple dots)', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: '....example..app',
        slug: 'notes',
      );

      expect(result.startsWith('https://'), isTrue);
      expect(result.contains('-notes'), isTrue);
    });

    test('should ignore malformed searchParams', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'dave.example.app',
        slug: 'drive',
        searchParams: [
          ['username'],
          ['key', 'value'],
        ],
      );

      expect(result, 'https://dave-drive.example.app/?key=value');
    });

    test('should not add fragment when hash is empty string', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'eve.example.app',
        slug: 'settings',
        hash: '',
      );

      expect(result, 'https://eve-settings.example.app/');
    });

    test('should keep original host when slug is null', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: null,
      );

      expect(result, 'https://alice.example.app/');
    });

    test('should keep original host when slug is empty', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: '',
      );

      expect(result, 'https://alice.example.app/');
    });

    test('should keep original host when slug is only whitespace', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'bob.example.app',
        slug: '   ',
      );

      expect(result, 'https://bob.example.app/');
    });


    test('generateWebLink should include path and no hash when hash is null', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: 'notes',
        pathname: 'welcome',
        hash: null,
      );

      expect(result, 'https://alice-notes.example.app/welcome');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should include path and no hash when hash is empty', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'bob.example.app',
        slug: 'drive',
        pathname: 'folder/123',
        hash: '',
      );

      expect(result, 'https://bob-drive.example.app/folder/123');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should return root path when pathname is null', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'charlie.example.app',
        slug: 'settings',
        pathname: null,
      );

      expect(result, 'https://charlie-settings.example.app/');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should include path and no hash when slug is null and only pathname is provided', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: null,
        pathname: 'welcome',
      );

      expect(result, 'https://alice.example.app/welcome');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should include path and no hash when slug is empty and only pathname is provided', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'bob.example.app',
        slug: '',
        pathname: 'dashboard',
      );

      expect(result, 'https://bob.example.app/dashboard');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should handle multi-segment pathname with leading slash when slug is null', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: null,
        pathname: '/name1/name2',
      );

      expect(result, 'https://alice.example.app/name1/name2');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should handle multi-segment pathname without leading slash when slug is null', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'bob.example.app',
        slug: null,
        pathname: 'name1/name2',
      );

      expect(result, 'https://bob.example.app/name1/name2');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should handle deep multi-segment pathname with leading slash when slug is empty', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'charlie.example.app',
        slug: '',
        pathname: '/a/b/c/d',
      );

      expect(result, 'https://charlie.example.app/a/b/c/d');
      expect(result.contains('#'), isFalse);
    });

    test('generateWebLink should handle deep multi-segment pathname without leading slash when slug is empty', () {
      final result = WebLinkGenerator.generateWebLink(
        workplaceFqdn: 'dave.example.app',
        slug: '',
        pathname: 'a/b/c/d',
      );

      expect(result, 'https://dave.example.app/a/b/c/d');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should return empty string on invalid FQDN', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: '',
        slug: 'notes',
      );

      expect(result, '');
    });

    test('safeGenerateWebLink should return valid URL on missing slug', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: '',
      );

      expect(result, 'https://alice.example.app/');
    });

    test('safeGenerateWebLink should still return valid URL when input ok', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'bob.example.app',
        slug: 'drive',
      );

      expect(result, 'https://bob-drive.example.app/');
    });

    test('safeGenerateWebLink should handle slug = null gracefully', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'example.com',
        slug: null,
      );

      expect(result, 'https://example.com/');
    });

    test('safeGenerateWebLink should include path and no hash when hash is null', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'dave.example.app',
        slug: 'profile',
        pathname: 'user/info',
        hash: null,
      );

      expect(result, 'https://dave-profile.example.app/user/info');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should include path and no hash when hash is empty', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'eve.example.app',
        slug: 'docs',
        pathname: 'help',
        hash: '',
      );

      expect(result, 'https://eve-docs.example.app/help');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should return root path when pathname is null', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'frank.example.app',
        slug: 'notes',
        pathname: null,
      );

      expect(result, 'https://frank-notes.example.app/');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should handle no slug and only pathname (slug = null)', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'charlie.example.app',
        slug: null,
        pathname: 'home',
      );

      expect(result, 'https://charlie.example.app/home');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should handle no slug and only pathname (slug = empty string)', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'dave.example.app',
        slug: '',
        pathname: 'portal',
      );

      expect(result, 'https://dave.example.app/portal');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should handle multi-segment pathname with leading slash and no slug', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'eve.example.app',
        slug: null,
        pathname: '/x/y/z',
      );

      expect(result, 'https://eve.example.app/x/y/z');
      expect(result.contains('#'), isFalse);
    });

    test('safeGenerateWebLink should handle multi-segment pathname without leading slash and no slug', () {
      final result = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: 'frank.example.app',
        slug: null,
        pathname: 'x/y/z',
      );

      expect(result, 'https://frank.example.app/x/y/z');
      expect(result.contains('#'), isFalse);
    });

  });
}

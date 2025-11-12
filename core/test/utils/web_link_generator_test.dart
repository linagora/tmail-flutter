import 'package:core/utils/web_link_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebLinkGenerator (with workplaceFqdn)', () {
    const generator = WebLinkGenerator();

    test('should generate correct link for flat subdomain', () {
      final result = generator.generateWebLink(
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
      final result = generator.generateWebLink(
        workplaceFqdn: 'bob.example.tools',
        pathname: 'files',
        hash: 'folder/123',
        slug: 'drive',
      );

      expect(result, 'https://bob-drive.example.tools/files#/folder/123');
    });

    test('should work with no search params', () {
      final result = generator.generateWebLink(
        workplaceFqdn: 'charlie.domain.com',
        slug: 'settings',
      );

      expect(result, 'https://charlie-settings.domain.com/');
    });

    test('should throw when workplaceFqdn is empty', () {
      expect(
        () => generator.generateWebLink(
          workplaceFqdn: '',
          slug: 'notes',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when workplaceFqdn only contains TLD', () {
      expect(
        () => generator.generateWebLink(
          workplaceFqdn: 'com',
          slug: 'notes',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when workplaceFqdn has no dot', () {
      expect(
        () => generator.generateWebLink(
          workplaceFqdn: 'localhost',
          slug: 'notes',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle malformed FQDN gracefully (multiple dots)', () {
      final result = generator.generateWebLink(
        workplaceFqdn: '....example..app',
        slug: 'notes',
      );

      expect(result.startsWith('https://'), isTrue);
      expect(result.contains('-notes'), isTrue);
    });

    test('should ignore malformed searchParams', () {
      final result = generator.generateWebLink(
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
      final result = generator.generateWebLink(
        workplaceFqdn: 'eve.example.app',
        slug: 'settings',
        hash: '',
      );

      expect(result, 'https://eve-settings.example.app/');
    });

    test('safeGenerateWebLink should return empty string on invalid FQDN', () {
      final result = generator.safeGenerateWebLink(
        workplaceFqdn: '',
        slug: 'notes',
      );

      expect(result, '');
    });

    test('safeGenerateWebLink should return empty string on missing slug', () {
      final result = generator.safeGenerateWebLink(
        workplaceFqdn: 'alice.example.app',
        slug: '',
      );

      expect(result, '');
    });

    test('safeGenerateWebLink should still return valid URL when input ok', () {
      final result = generator.safeGenerateWebLink(
        workplaceFqdn: 'bob.example.app',
        slug: 'drive',
      );

      expect(result, 'https://bob-drive.example.app/');
    });
  });
}

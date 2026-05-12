import 'package:flutter_test/flutter_test.dart';
import 'package:model/download_all/download_all_capability.dart';

void main() {
  group('DownloadAllCapability.normalizedEndpoint', () {
    test('should normalize double slashes from server-returned endpoint', () {
      final capability = DownloadAllCapability(
        endpoint: 'http://localhost//downloadAll/{accountId}/{emailId}?name={name}',
      );

      expect(
        capability.normalizedEndpoint,
        'http://localhost/downloadAll/{accountId}/{emailId}?name={name}',
      );
    });

    test('should leave endpoint unchanged when path has single slash', () {
      final capability = DownloadAllCapability(
        endpoint: 'http://localhost/downloadAll/{accountId}/{emailId}?name={name}',
      );

      expect(
        capability.normalizedEndpoint,
        'http://localhost/downloadAll/{accountId}/{emailId}?name={name}',
      );
    });

    test('should return null when endpoint is null', () {
      final capability = DownloadAllCapability(endpoint: null);

      expect(capability.normalizedEndpoint, isNull);
    });

    test('should preserve URI template variables after normalization', () {
      final capability = DownloadAllCapability(
        endpoint: 'https://example.com//api/{accountId}/{emailId}?name={name}',
      );

      expect(capability.normalizedEndpoint, contains('{accountId}'));
      expect(capability.normalizedEndpoint, contains('{emailId}'));
      expect(capability.normalizedEndpoint, contains('{name}'));
    });

    test('should collapse triple slashes to single slash', () {
      final capability = DownloadAllCapability(
        endpoint: 'http://localhost///downloadAll/{accountId}/{emailId}',
      );

      expect(
        capability.normalizedEndpoint,
        'http://localhost/downloadAll/{accountId}/{emailId}',
      );
    });

    test('should collapse trailing double slash', () {
      final capability = DownloadAllCapability(
        endpoint: 'http://localhost/downloadAll//',
      );

      expect(capability.normalizedEndpoint, 'http://localhost/downloadAll/');
    });

    test('should return empty string when endpoint is empty', () {
      final capability = DownloadAllCapability(endpoint: '');

      expect(capability.normalizedEndpoint, '');
    });

    test('should normalize https endpoint with double slash', () {
      final capability = DownloadAllCapability(
        endpoint: 'https://example.com//api/{accountId}/{emailId}',
      );

      expect(
        capability.normalizedEndpoint,
        'https://example.com/api/{accountId}/{emailId}',
      );
    });
  });
}

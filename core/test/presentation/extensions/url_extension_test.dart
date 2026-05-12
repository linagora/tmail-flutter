import 'package:core/presentation/extensions/url_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('URLExtension.normalizePathSlashes', () {
    test('should collapse double slash in path', () {
      expect(
        'http://localhost//download/{accountId}/{blobId}'.normalizePathSlashes(),
        'http://localhost/download/{accountId}/{blobId}',
      );
    });

    test('should collapse triple slash in path', () {
      expect(
        'http://localhost///jmap'.normalizePathSlashes(),
        'http://localhost/jmap',
      );
    });

    test('should not alter a path with single slashes', () {
      expect(
        'http://localhost/upload/{accountId}'.normalizePathSlashes(),
        'http://localhost/upload/{accountId}',
      );
    });

    test('should preserve :// in the scheme', () {
      expect(
        'http://localhost//path'.normalizePathSlashes(),
        'http://localhost/path',
      );
    });

    test('should preserve URI template variables', () {
      const url = 'http://localhost//downloadAll/{accountId}/{emailId}?name={name}';
      expect(
        url.normalizePathSlashes(),
        'http://localhost/downloadAll/{accountId}/{emailId}?name={name}',
      );
    });

    test('should handle websocket URL with double slash', () {
      expect(
        'ws://localhost//jmap/ws'.normalizePathSlashes(),
        'ws://localhost/jmap/ws',
      );
    });

    test('should return empty string unchanged', () {
      expect(''.normalizePathSlashes(), '');
    });

    test('should collapse trailing double slash', () {
      expect(
        'http://localhost/path//'.normalizePathSlashes(),
        'http://localhost/path/',
      );
    });

    test('should collapse four or more consecutive slashes', () {
      expect(
        'http://localhost////path'.normalizePathSlashes(),
        'http://localhost/path',
      );
    });

    test('should preserve https:// scheme while normalizing path', () {
      expect(
        'https://localhost//path'.normalizePathSlashes(),
        'https://localhost/path',
      );
    });

    test('should preserve port number while normalizing path', () {
      expect(
        'http://localhost:8080//path'.normalizePathSlashes(),
        'http://localhost:8080/path',
      );
    });

    test('should collapse standalone double slash to single slash', () {
      expect('//'.normalizePathSlashes(), '/');
    });
  });
}


import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('method convertToQualifiedUrl test', () {

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `https://domain.com/jmap`', () async {
      final baseUrl =  Uri.parse('https://domain.com');
      final sourceUrl =  Uri.parse('https://domain.com/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `/jmap/`', () async {
      final baseUrl =  Uri.parse('https://domain.com');
      final sourceUrl =  Uri.parse('/jmap/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `/jmap`', () async {
      final baseUrl =  Uri.parse('https://domain.com');
      final sourceUrl =  Uri.parse('/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com/jmap` and sourceUrl is empty', () async {
      final baseUrl =  Uri.parse('https://domain.com/jmap');
      final sourceUrl =  Uri.parse('');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com/jmap` and sourceUrl is `/`', () async {
      final baseUrl =  Uri.parse('https://domain.com/jmap');
      final sourceUrl =  Uri.parse('/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });
  });
}
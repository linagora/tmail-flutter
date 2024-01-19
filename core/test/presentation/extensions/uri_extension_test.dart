
import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('method convertToQualifiedUrl test', () {

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and originUrl is `https://domain.com/jmap`', () async {
      const baseUrl = 'https://domain.com';
      final originUrl = Uri.parse('https://domain.com/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = originUrl.toQualifiedUrl(baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and originUrl is `/jmap/`', () async {
      const baseUrl = 'https://domain.com';
      final originUrl = Uri.parse('/jmap/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = originUrl.toQualifiedUrl(baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and originUrl is `/jmap`', () async {
      const baseUrl = 'https://domain.com';
      final originUrl = Uri.parse('/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = originUrl.toQualifiedUrl(baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com/jmap` and originUrl is empty', () async {
      const baseUrl = 'https://domain.com/jmap';
      final originUrl = Uri.parse('');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = originUrl.toQualifiedUrl(baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com/jmap` and originUrl is `/`', () async {
      const baseUrl = 'https://domain.com/jmap';
      final originUrl = Uri.parse('/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = originUrl.toQualifiedUrl(baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `http://domain.com` and originUrl is `http://localhost.com/jmap`', () async {
      const baseUrl = 'http://domain.com';
      final originUrl = Uri.parse('http://localhost.com/jmap');

      final qualifiedUrlExpected = Uri.parse('http://localhost.com/jmap');
      final qualifiedUrlResult = originUrl.toQualifiedUrl(baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });
  });
}

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('method convertToQualifiedUrl test', () {

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `https://domain.com/jmap`', () async {
      final baseUrl = Uri.parse('https://domain.com');
      final sourceUrl = Uri.parse('https://domain.com/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `https://domain.com/jmap/`', () async {
      final baseUrl = Uri.parse('https://domain.com');
      final sourceUrl = Uri.parse('https://domain.com/jmap/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap/');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `/jmap/`', () async {
      final baseUrl = Uri.parse('https://domain.com');
      final sourceUrl = Uri.parse('/jmap/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap/');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com` and sourceUrl is `/jmap`', () async {
      final baseUrl = Uri.parse('https://domain.com');
      final sourceUrl = Uri.parse('/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com/jmap` and sourceUrl is empty', () async {
      final baseUrl = Uri.parse('https://domain.com/jmap');
      final sourceUrl = Uri.parse('');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com/jmap` and sourceUrl is `/`', () async {
      final baseUrl = Uri.parse('https://domain.com/jmap');
      final sourceUrl = Uri.parse('/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com/jmap/');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com:2000/jmap` and sourceUrl is `https://domain.com:2001/jmap`', () async {
      final baseUrl = Uri.parse('https://domain.com:2000/jmap');
      final sourceUrl = Uri.parse('https://domain.com:2001/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com:2001/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com:2000/jmap` and sourceUrl is `https://domain.com:2001/jmap/`', () async {
      final baseUrl = Uri.parse('https://domain.com:2000/jmap');
      final sourceUrl = Uri.parse('https://domain.com:2001/jmap/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com:2001/jmap/');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is `https://domain.com:20001/jmap` and sourceUrl is `https://domain.com:2001/jmap`', () async {
      final baseUrl = Uri.parse('https://domain.com:2001/jmap');
      final sourceUrl = Uri.parse('https://domain.com:2001/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com:2001/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is localhost and sourceUrl is `https://domain.com:2001/basicauth/jmap`', () async {
      final baseUrl = Uri.parse('https://localhost:9080/basicauth');
      final sourceUrl = Uri.parse('https://domain.com:2001/basicauth/jmap');

      final qualifiedUrlExpected = Uri.parse('https://domain.com:2001/basicauth/jmap');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });

    test('convertToQualifiedUrl() should return qualified url when baseUrl is localhost and sourceUrl is `https://domain.com:2001/basicauth/jmap/`', () async {
      final baseUrl = Uri.parse('https://localhost:9080/basicauth');
      final sourceUrl = Uri.parse('https://domain.com:2001/basicauth/jmap/');

      final qualifiedUrlExpected = Uri.parse('https://domain.com:2001/basicauth/jmap/');
      final qualifiedUrlResult = sourceUrl.toQualifiedUrl(baseUrl: baseUrl);

      expect(qualifiedUrlResult, equals(qualifiedUrlExpected));
    });
  });

  group('URIExtension.ensureWebSocketUri', () {
    test('Should keep ws scheme unchanged', () {
      final uri = Uri.parse('ws://example.com/socket');
      expect(uri.ensureWebSocketUri().toString(), 'ws://example.com/socket');
    });

    test('Should keep wss scheme unchanged', () {
      final uri = Uri.parse('wss://example.com/socket');
      expect(uri.ensureWebSocketUri().toString(), 'wss://example.com/socket');
    });

    test('Should convert http to wss', () {
      final uri = Uri.parse('http://example.com/socket');
      expect(uri.ensureWebSocketUri().toString(), 'wss://example.com/socket');
    });

    test('Should convert https to wss', () {
      final uri = Uri.parse('https://example.com/socket');
      expect(uri.ensureWebSocketUri().toString(), 'wss://example.com/socket');
    });

    test('Should keep path and query parameters unchanged', () {
      final uri = Uri.parse('http://example.com/socket?token=123');
      expect(uri.ensureWebSocketUri().toString(), 'wss://example.com/socket?token=123');
    });

    test('Should handle URIs without a scheme (default to wss)', () {
      final uri = Uri.parse('//example.com/socket');
      expect(uri.ensureWebSocketUri().toString(), 'wss://example.com/socket');
    });
  });
}
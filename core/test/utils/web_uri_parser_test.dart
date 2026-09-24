import 'package:core/utils/web_uri_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebUriParser::tryParse', () {
    final validAbsoluteCases = [
      (
        description: 'an HTTPS URL',
        value: 'https://calendar.example.com/path',
        expected: 'https://calendar.example.com/path',
      ),
      (
        description: 'an uppercase HTTPS URL surrounded by whitespace',
        value: '  HTTPS://CALENDAR.EXAMPLE.COM:8443/path  ',
        expected: 'https://calendar.example.com:8443/path',
      ),
      (
        description: 'an HTTPS URL at the maximum port boundary',
        value: 'https://calendar.example.com:65535/path',
        expected: 'https://calendar.example.com:65535/path',
      ),
      (
        description: 'an HTTPS URL with a query and fragment',
        value: 'https://calendar.example.com/path?tenant=one#event',
        expected: 'https://calendar.example.com/path?tenant=one#event',
      ),
      (
        description: 'an HTTPS IPv4 URL with an explicit scheme',
        value: 'https://192.168.1.10/path',
        expected: 'https://192.168.1.10/path',
      ),
      (
        description: 'an HTTPS URL with valid mixed-case percent escapes',
        value: 'https://calendar.example.com/%7Bevent%7d',
        expected: 'https://calendar.example.com/%7Bevent%7D',
      ),
    ];

    for (final testCase in validAbsoluteCases) {
      test('SHOULD parse ${testCase.description}', () {
        _expectTryParse(testCase.value, testCase.expected);
      });
    }

    final invalidDefaultCases = [
      (description: 'the value is missing', value: null),
      (description: 'the value is blank', value: '   '),
      (description: 'the URL is relative', value: 'calendar/path'),
      (description: 'the URL uses public HTTP', value: 'http://example.com'),
      (description: 'the URL uses HTTP localhost', value: 'http://localhost'),
      (description: 'the URL uses an unsafe scheme', value: 'javascript:alert(1)'),
      (
        description: 'the URL contains user info',
        value: 'https://user@calendar.example.com',
      ),
      (
        description: 'the URL contains an out-of-range port',
        value: 'https://calendar.example.com:65536',
      ),
      (
        description: 'the URL contains an incomplete percent escape',
        value: 'https://calendar.example.com/%',
      ),
      (
        description: 'the URL contains a non-hex first escape digit',
        value: 'https://calendar.example.com/%G0',
      ),
      (
        description: 'the URL contains a non-hex second escape digit',
        value: 'https://calendar.example.com/%0G',
      ),
      (description: 'the URL has no host', value: 'https://'),
    ];

    for (final testCase in invalidDefaultCases) {
      test('SHOULD return null WHEN ${testCase.description}', () {
        _expectTryParse(testCase.value, isNull);
      });
    }

    final inferredHttpsCases = [
      (
        description: 'a scheme-relative qualified domain',
        value: '//calendar.example.com/path',
        expected: 'https://calendar.example.com/path',
      ),
      (
        description: 'a qualified domain',
        value: 'calendar.example.com',
        expected: 'https://calendar.example.com',
      ),
      (
        description: 'a qualified domain with a port and path',
        value: 'calendar.example.com:8443/path',
        expected: 'https://calendar.example.com:8443/path',
      ),
    ];

    for (final testCase in inferredHttpsCases) {
      test('SHOULD infer HTTPS FROM ${testCase.description}', () {
        _expectTryParse(
          testCase.value,
          testCase.expected,
          inferMissingScheme: true,
        );
      });
    }

    test('SHOULD allow HTTP localhost WHEN explicitly enabled', () {
      _expectTryParse(
        'http://localhost:3000/path',
        'http://localhost:3000/path',
        allowHttpLocalhost: true,
      );
    });

    test('SHOULD infer HTTP for localhost WHEN explicitly enabled', () {
      _expectTryParse(
        'LOCALHOST:3000/path',
        'http://localhost:3000/path',
        inferMissingScheme: true,
        allowHttpLocalhost: true,
      );
    });

    final invalidInferenceCases = [
      (description: 'a relative path', value: 'calendar/path'),
      (description: 'a single-label host', value: 'calendar'),
      (description: 'an IPv4 address', value: '192.168.1.10/path'),
      (description: 'a scheme-relative IPv4 address', value: '//192.168.1.10'),
      (description: 'an invalid domain label', value: 'calendar_.example.com'),
      (description: 'a trailing-dot domain', value: 'calendar.example.com.'),
      (description: 'a malformed port', value: 'calendar.example.com:invalid'),
      (
        description: 'an out-of-range port',
        value: 'calendar.example.com:65536',
      ),
      (
        description: 'a bare-domain user-info spoof',
        value: 'calendar.example.com@evil.example',
      ),
      (
        description: 'a scheme-relative user-info spoof',
        value: '//calendar.example.com@evil.example',
      ),
      (
        description: 'a hostname prefixed with localhost',
        value: 'localhost.evil.example/path',
      ),
    ];

    for (final testCase in invalidInferenceCases) {
      test('SHOULD not infer a scheme FROM ${testCase.description}', () {
        _expectTryParse(
          testCase.value,
          isNull,
          inferMissingScheme: true,
          allowHttpLocalhost: true,
        );
      });
    }

    final dnsLabelBoundaryCases = [
      (
        description: 'accept a DNS label at the 63-character boundary',
        length: 63,
        matcher: isNotNull,
      ),
      (
        description: 'reject a DNS label longer than 63 characters',
        length: 64,
        matcher: isNull,
      ),
    ];

    for (final testCase in dnsLabelBoundaryCases) {
      test('SHOULD ${testCase.description}', () {
        final label = List.filled(testCase.length, 'a').join();

        _expectTryParse(
          '$label.example',
          testCase.matcher,
          inferMissingScheme: true,
        );
      });
    }

    test('SHOULD reject a host longer than 253 characters', () {
      final label = List.filled(63, 'a').join();
      final host = List.filled(4, label).join('.');

      expect(host.length, greaterThan(253));
      _expectTryParse(
        host,
        isNull,
        inferMissingScheme: true,
      );
    });
  });
}

void _expectTryParse(
  String? value,
  Object? matcher, {
  bool inferMissingScheme = false,
  bool allowHttpLocalhost = false,
}) {
  expect(
    WebUriParser.tryParse(
      value,
      inferMissingScheme: inferMissingScheme,
      allowHttpLocalhost: allowHttpLocalhost,
    )?.toString(),
    matcher,
  );
}

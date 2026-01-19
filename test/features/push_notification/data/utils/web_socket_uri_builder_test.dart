import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/push_notification/data/utils/web_socket_uri_builder.dart';

void main() {
  group('WebSocketUriBuilder', () {
    late Uri baseUri;

    setUp(() {
      baseUri = Uri.parse('wss://mail.example.com/jmap/ws');
    });

    group('addQueryParam', () {
      test('should add a query parameter to empty URI', () {
        final result = WebSocketUriBuilder.addQueryParam(baseUri, 'ticket', 'abc123');

        expect(result.queryParameters['ticket'], equals('abc123'));
        expect(result.scheme, equals('wss'));
        expect(result.host, equals('mail.example.com'));
        expect(result.path, equals('/jmap/ws'));
      });

      test('should preserve existing query parameters', () {
        final uriWithParams = Uri.parse('wss://mail.example.com/jmap/ws?existing=value');
        final result = WebSocketUriBuilder.addQueryParam(uriWithParams, 'new', 'param');

        expect(result.queryParameters['existing'], equals('value'));
        expect(result.queryParameters['new'], equals('param'));
      });

      test('should overwrite existing parameter with same key', () {
        final uriWithParams = Uri.parse('wss://mail.example.com/jmap/ws?key=old');
        final result = WebSocketUriBuilder.addQueryParam(uriWithParams, 'key', 'new');

        expect(result.queryParameters['key'], equals('new'));
      });
    });

    group('addQueryParams', () {
      test('should add multiple query parameters', () {
        final result = WebSocketUriBuilder.addQueryParams(
          baseUri,
          {'param1': 'value1', 'param2': 'value2'},
        );

        expect(result.queryParameters['param1'], equals('value1'));
        expect(result.queryParameters['param2'], equals('value2'));
      });

      test('should preserve existing and add new parameters', () {
        final uriWithParams = Uri.parse('wss://mail.example.com/jmap/ws?existing=value');
        final result = WebSocketUriBuilder.addQueryParams(
          uriWithParams,
          {'new1': 'val1', 'new2': 'val2'},
        );

        expect(result.queryParameters['existing'], equals('value'));
        expect(result.queryParameters['new1'], equals('val1'));
        expect(result.queryParameters['new2'], equals('val2'));
      });
    });

    group('redactSensitiveParams', () {
      test('should redact access_token parameter', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?access_token=secret123');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        // The [REDACTED] gets URL-encoded in the string representation
        expect(result, isNot(contains('secret123')));
        expect(result, contains('access_token='));
      });

      test('should redact authorization parameter', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?authorization=Basic%20secret');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        expect(result, isNot(contains('secret')));
        expect(result, contains('authorization='));
      });

      test('should redact ticket parameter', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?ticket=secret-ticket');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        expect(result, isNot(contains('secret-ticket')));
        expect(result, contains('ticket='));
      });

      test('should not modify URI without sensitive parameters', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?safe=value');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        expect(result, equals(uri.toString()));
        expect(result, contains('safe=value'));
      });

      test('should preserve non-sensitive parameters while redacting sensitive ones', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?access_token=secret&safe=value');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        expect(result, isNot(contains('secret')));
        expect(result, contains('safe=value'));
        expect(result, contains('access_token='));
      });

      test('should handle URI with no query parameters', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        expect(result, equals(uri.toString()));
      });

      test('should redact multiple sensitive parameters', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?access_token=tok&ticket=tkt&authorization=auth');
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        // All sensitive values should be redacted
        expect(result, isNot(contains('=tok')));
        expect(result, isNot(contains('=tkt')));
        expect(result, isNot(contains('=auth')));
        // Keys should still be present
        expect(result, contains('access_token='));
        expect(result, contains('ticket='));
        expect(result, contains('authorization='));
      });
    });

    group('containsSensitiveParams', () {
      test('should return true when access_token is present', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?access_token=token');
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isTrue);
      });

      test('should return true when authorization is present', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?authorization=Basic%20creds');
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isTrue);
      });

      test('should return true when ticket is present', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?ticket=abc');
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isTrue);
      });

      test('should return false when no sensitive params are present', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws?safe=value');
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isFalse);
      });

      test('should return false for empty query parameters', () {
        final uri = Uri.parse('wss://mail.example.com/jmap/ws');
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isFalse);
      });
    });
  });
}

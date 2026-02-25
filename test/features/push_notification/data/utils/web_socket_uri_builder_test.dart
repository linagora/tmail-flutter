import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/push_notification/data/utils/web_socket_uri_builder.dart';

void main() {
  group('WebSocketUriBuilder', () {
    group('addQueryParam', () {
      test('should add single query parameter to URI without params', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws');

        // Act
        final result = WebSocketUriBuilder.addQueryParam(uri, 'key', 'value');

        // Assert
        expect(result.queryParameters['key'], equals('value'));
        expect(result.toString(), equals('wss://example.com/ws?key=value'));
      });

      test('should preserve existing query parameters', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?existing=param');

        // Act
        final result = WebSocketUriBuilder.addQueryParam(uri, 'new', 'value');

        // Assert
        expect(result.queryParameters['existing'], equals('param'));
        expect(result.queryParameters['new'], equals('value'));
      });

      test('should override existing parameter with same key', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?key=old');

        // Act
        final result = WebSocketUriBuilder.addQueryParam(uri, 'key', 'new');

        // Assert
        expect(result.queryParameters['key'], equals('new'));
      });
    });

    group('addQueryParams', () {
      test('should add multiple query parameters', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws');

        // Act
        final result = WebSocketUriBuilder.addQueryParams(uri, {
          'key1': 'value1',
          'key2': 'value2',
        });

        // Assert
        expect(result.queryParameters['key1'], equals('value1'));
        expect(result.queryParameters['key2'], equals('value2'));
      });

      test('should preserve existing and add new parameters', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?existing=param');

        // Act
        final result = WebSocketUriBuilder.addQueryParams(uri, {
          'new1': 'value1',
          'new2': 'value2',
        });

        // Assert
        expect(result.queryParameters['existing'], equals('param'));
        expect(result.queryParameters['new1'], equals('value1'));
        expect(result.queryParameters['new2'], equals('value2'));
      });
    });

    group('redactSensitiveParams', () {
      test('should redact access_token parameter', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?access_token=secret123');

        // Act
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);
        final decodedResult = Uri.decodeFull(result);

        // Assert
        expect(decodedResult, contains('access_token=[REDACTED]'));
        expect(decodedResult, isNot(contains('secret123')));
      });

      test('should redact authorization parameter', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?authorization=Basic%20secret');

        // Act
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);
        final decodedResult = Uri.decodeFull(result);

        // Assert
        expect(decodedResult, contains('authorization=[REDACTED]'));
        expect(decodedResult, isNot(contains('secret')));
      });

      test('should redact ticket parameter', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?ticket=ticket123');

        // Act
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);
        final decodedResult = Uri.decodeFull(result);

        // Assert
        expect(decodedResult, contains('ticket=[REDACTED]'));
        expect(decodedResult, isNot(contains('ticket123')));
      });

      test('should preserve non-sensitive parameters', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?access_token=secret&safe=value');

        // Act
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);
        final decodedResult = Uri.decodeFull(result);

        // Assert
        expect(decodedResult, contains('access_token=[REDACTED]'));
        expect(decodedResult, contains('safe=value'));
      });

      test('should return unchanged URI if no sensitive params', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?safe=value');

        // Act
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);

        // Assert
        expect(result, equals(uri.toString()));
      });

      test('should handle multiple sensitive parameters', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?access_token=token&ticket=ticket123');

        // Act
        final result = WebSocketUriBuilder.redactSensitiveParams(uri);
        final decodedResult = Uri.decodeFull(result);

        // Assert
        expect(decodedResult, contains('access_token=[REDACTED]'));
        expect(decodedResult, contains('ticket=[REDACTED]'));
        // Note: 'token' appears in 'access_token' key, so we check the value is redacted differently
        expect(result, isNot(contains('ticket123')));
      });
    });

    group('containsSensitiveParams', () {
      test('should return true for access_token', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?access_token=secret');

        // Act & Assert
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isTrue);
      });

      test('should return true for authorization', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?authorization=Basic%20secret');

        // Act & Assert
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isTrue);
      });

      test('should return true for ticket', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?ticket=ticket123');

        // Act & Assert
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isTrue);
      });

      test('should return false for non-sensitive params', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws?safe=value');

        // Act & Assert
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isFalse);
      });

      test('should return false for URI without params', () {
        // Arrange
        final uri = Uri.parse('wss://example.com/ws');

        // Act & Assert
        expect(WebSocketUriBuilder.containsSensitiveParams(uri), isFalse);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_capability_provider.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';

void main() {
  late WebSocketCapabilityProvider provider;

  setUp(() {
    provider = const WebSocketCapabilityProvider();
  });

  group('WebSocketCapabilityProvider', () {
    group('hasCapability', () {
      test('should return true when WebSocket capability is present', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: true);

        // Act
        final result = provider.hasCapability(session);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when WebSocket capability is absent', () {
        // Arrange
        final session = _createSessionWithoutWebSocket();

        // Act
        final result = provider.hasCapability(session);

        // Assert
        expect(result, isFalse);
      });
    });

    group('supportsPush', () {
      test('should return true when supportsPush is true', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: true);

        // Act
        final result = provider.supportsPush(session);

        // Assert
        expect(result, isTrue);
      });

      test('should return true when supportsPush is null (Stalwart behavior)', () {
        // Arrange - Stalwart omits supportsPush, treating it as null
        final session = _createSessionWithWebSocket(supportsPush: null);

        // Act
        final result = provider.supportsPush(session);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when supportsPush is explicitly false', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: false);

        // Act
        final result = provider.supportsPush(session);

        // Assert
        expect(result, isFalse);
      });
    });

    group('validateCapability', () {
      test('should not throw when WebSocket capability supports push', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: true);

        // Act & Assert
        expect(() => provider.validateCapability(session), returnsNormally);
      });

      test('should not throw when supportsPush is null (Stalwart)', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: null);

        // Act & Assert
        expect(() => provider.validateCapability(session), returnsNormally);
      });

      test('should throw WebSocketPushNotSupportedException when capability absent', () {
        // Arrange
        final session = _createSessionWithoutWebSocket();

        // Act & Assert
        expect(
          () => provider.validateCapability(session),
          throwsA(isA<WebSocketPushNotSupportedException>()),
        );
      });

      test('should throw WebSocketPushNotSupportedException when supportsPush is false', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: false);

        // Act & Assert
        expect(
          () => provider.validateCapability(session),
          throwsA(isA<WebSocketPushNotSupportedException>()),
        );
      });
    });

    group('getWebSocketUri', () {
      test('should return URI when available', () {
        // Arrange
        final expectedUri = Uri.parse('wss://example.com/ws');
        final session = _createSessionWithWebSocket(
          supportsPush: true,
          url: expectedUri,
        );

        // Act
        final result = provider.getWebSocketUri(session);

        // Assert
        expect(result, equals(expectedUri));
      });

      test('should throw WebSocketUriUnavailableException when URL is null', () {
        // Arrange
        final session = _createSessionWithWebSocket(
          supportsPush: true,
          url: null,
        );

        // Act & Assert
        expect(
          () => provider.getWebSocketUri(session),
          throwsA(isA<WebSocketUriUnavailableException>()),
        );
      });
    });

    group('getCapability', () {
      test('should return WebSocketCapability when present', () {
        // Arrange
        final session = _createSessionWithWebSocket(supportsPush: true);

        // Act
        final result = provider.getCapability(session);

        // Assert
        expect(result, isA<WebSocketCapability>());
        expect(result?.supportsPush, isTrue);
      });

      test('should return null when capability is absent', () {
        // Arrange
        final session = _createSessionWithoutWebSocket();

        // Act
        final result = provider.getCapability(session);

        // Assert
        expect(result, isNull);
      });
    });
  });
}

Session _createSessionWithWebSocket({
  bool? supportsPush,
  Uri? url = const _DefaultUri(),
}) {
  final actualUrl = url is _DefaultUri ? Uri.parse('wss://example.com/ws') : url;
  return Session(
    {
      CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
        supportsPush: supportsPush,
        url: actualUrl,
      ),
    },
    {},
    {},
    UserName('test@example.com'),
    Uri.parse('https://example.com/jmap'),
    Uri.parse('https://example.com/download/{accountId}/{blobId}/{name}'),
    Uri.parse('https://example.com/upload/{accountId}'),
    Uri.parse('https://example.com/events/{types}/{closeAfter}/{ping}'),
    State('test-state'),
  );
}

Session _createSessionWithoutWebSocket() {
  return Session(
    {},
    {},
    {},
    UserName('test@example.com'),
    Uri.parse('https://example.com/jmap'),
    Uri.parse('https://example.com/download/{accountId}/{blobId}/{name}'),
    Uri.parse('https://example.com/upload/{accountId}'),
    Uri.parse('https://example.com/events/{types}/{closeAfter}/{ping}'),
    State('test-state'),
  );
}

/// Sentinel class to distinguish between 'not provided' and 'explicitly null'
class _DefaultUri implements Uri {
  const _DefaultUri();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

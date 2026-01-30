import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/basic_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/no_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/ticket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/token_auth_strategy.dart';

import 'mocks/mock_authorization_interceptors.mocks.dart';

void main() {
  final testAccountId = AccountId(Id('test-account-id'));
  final baseUri = Uri.parse('wss://example.com/ws');

  group('TokenAuthStrategy', () {
    late MockAuthorizationInterceptors mockAuthInterceptors;
    late TokenAuthStrategy strategy;

    setUp(() {
      mockAuthInterceptors = MockAuthorizationInterceptors();
      strategy = TokenAuthStrategy(mockAuthInterceptors);
    });

    test('should add access_token query parameter when token is available', () async {
      // Arrange
      const testToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.test-token';
      when(mockAuthInterceptors.currentToken).thenReturn(testToken);
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result.queryParameters['access_token'], equals(testToken));
      expect(result.host, equals('example.com'));
      expect(result.path, equals('/ws'));
    });

    test('should return base URI when token is null', () async {
      // Arrange
      when(mockAuthInterceptors.currentToken).thenReturn(null);
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result.queryParameters.containsKey('access_token'), isFalse);
      expect(result, equals(baseUri));
    });

    test('should return base URI when token is empty', () async {
      // Arrange
      when(mockAuthInterceptors.currentToken).thenReturn('');
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result.queryParameters.containsKey('access_token'), isFalse);
      expect(result, equals(baseUri));
    });

    test('should preserve existing query parameters', () async {
      // Arrange
      const testToken = 'test-token';
      when(mockAuthInterceptors.currentToken).thenReturn(testToken);
      final uriWithParams = Uri.parse('wss://example.com/ws?existing=param');
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(uriWithParams, session, testAccountId);

      // Assert
      expect(result.queryParameters['existing'], equals('param'));
      expect(result.queryParameters['access_token'], equals(testToken));
    });
  });

  group('BasicAuthStrategy', () {
    late MockAuthorizationInterceptors mockAuthInterceptors;
    late BasicAuthStrategy strategy;

    setUp(() {
      mockAuthInterceptors = MockAuthorizationInterceptors();
      strategy = BasicAuthStrategy(mockAuthInterceptors);
    });

    test('should add authorization query parameter when credentials available', () async {
      // Arrange
      const testCredentials = 'dXNlcm5hbWU6cGFzc3dvcmQ='; // base64(username:password)
      when(mockAuthInterceptors.basicAuthCredentials).thenReturn(testCredentials);
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result.queryParameters['authorization'], equals('Basic $testCredentials'));
    });

    test('should return base URI when credentials are null', () async {
      // Arrange
      when(mockAuthInterceptors.basicAuthCredentials).thenReturn(null);
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result.queryParameters.containsKey('authorization'), isFalse);
      expect(result, equals(baseUri));
    });
  });

  group('NoAuthStrategy', () {
    late NoAuthStrategy strategy;

    setUp(() {
      strategy = const NoAuthStrategy();
    });

    test('should return base URI unchanged', () async {
      // Arrange
      final session = _createTestSession();

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result, equals(baseUri));
    });
  });

  group('TicketAuthStrategy', () {
    late MockWebSocketApi mockWebSocketApi;
    late TicketAuthStrategy strategy;

    setUp(() {
      mockWebSocketApi = MockWebSocketApi();
      strategy = TicketAuthStrategy(mockWebSocketApi);
    });

    test('should add ticket query parameter from WebSocket API', () async {
      // Arrange
      const testTicket = 'test-ticket-12345';
      final session = _createTestSession();
      when(mockWebSocketApi.getWebSocketTicket(session, testAccountId))
          .thenAnswer((_) async => testTicket);

      // Act
      final result = await strategy.buildConnectionUri(baseUri, session, testAccountId);

      // Assert
      expect(result.queryParameters['ticket'], equals(testTicket));
      verify(mockWebSocketApi.getWebSocketTicket(session, testAccountId)).called(1);
    });

    test('should preserve existing query parameters', () async {
      // Arrange
      const testTicket = 'test-ticket-12345';
      final uriWithParams = Uri.parse('wss://example.com/ws?existing=param&other=value');
      final session = _createTestSession();
      when(mockWebSocketApi.getWebSocketTicket(session, testAccountId))
          .thenAnswer((_) async => testTicket);

      // Act
      final result = await strategy.buildConnectionUri(uriWithParams, session, testAccountId);

      // Assert
      expect(result.queryParameters['existing'], equals('param'));
      expect(result.queryParameters['other'], equals('value'));
      expect(result.queryParameters['ticket'], equals(testTicket));
    });
  });
}

Session _createTestSession() {
  return Session(
    {
      CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
        supportsPush: true,
        url: Uri.parse('wss://example.com/ws'),
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

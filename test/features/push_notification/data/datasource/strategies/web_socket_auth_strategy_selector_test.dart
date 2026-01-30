import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/basic_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/no_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/ticket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/token_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy_selector.dart';

import 'mocks/mock_authorization_interceptors.mocks.dart';

void main() {
  late WebSocketAuthStrategySelector selector;
  late MockAuthorizationInterceptors mockAuthInterceptors;
  late MockWebSocketApi mockWebSocketApi;

  setUp(() {
    mockAuthInterceptors = MockAuthorizationInterceptors();
    mockWebSocketApi = MockWebSocketApi();
    selector = WebSocketAuthStrategySelector(mockWebSocketApi, mockAuthInterceptors);
  });

  group('WebSocketAuthStrategySelector', () {
    group('selectStrategy', () {
      test('should return TicketAuthStrategy when James ticket capability is present', () {
        // Arrange
        final session = _createSessionWithCapabilities({
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('wss://example.com/ws'),
          ),
          CapabilityIdentifier.jmapWebSocketTicket: DefaultCapability({}),
        });

        // Act
        final strategy = selector.selectStrategy(session);

        // Assert
        expect(strategy, isA<TicketAuthStrategy>());
      });

      test('should return TokenAuthStrategy when OIDC auth and no ticket capability', () {
        // Arrange
        final session = _createSessionWithCapabilities({
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('wss://example.com/ws'),
          ),
        });
        when(mockAuthInterceptors.authenticationType).thenReturn(AuthenticationType.oidc);

        // Act
        final strategy = selector.selectStrategy(session);

        // Assert
        expect(strategy, isA<TokenAuthStrategy>());
      });

      test('should return BasicAuthStrategy when basic auth and no ticket capability', () {
        // Arrange
        final session = _createSessionWithCapabilities({
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('wss://example.com/ws'),
          ),
        });
        when(mockAuthInterceptors.authenticationType).thenReturn(AuthenticationType.basic);

        // Act
        final strategy = selector.selectStrategy(session);

        // Assert
        expect(strategy, isA<BasicAuthStrategy>());
      });

      test('should return NoAuthStrategy when auth type is none and no ticket capability', () {
        // Arrange
        final session = _createSessionWithCapabilities({
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('wss://example.com/ws'),
          ),
        });
        when(mockAuthInterceptors.authenticationType).thenReturn(AuthenticationType.none);

        // Act
        final strategy = selector.selectStrategy(session);

        // Assert
        expect(strategy, isA<NoAuthStrategy>());
      });

      test('should prioritize ticket auth over OIDC when both available', () {
        // Arrange
        final session = _createSessionWithCapabilities({
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            supportsPush: true,
            url: Uri.parse('wss://example.com/ws'),
          ),
          CapabilityIdentifier.jmapWebSocketTicket: DefaultCapability({}),
        });
        when(mockAuthInterceptors.authenticationType).thenReturn(AuthenticationType.oidc);

        // Act
        final strategy = selector.selectStrategy(session);

        // Assert
        expect(strategy, isA<TicketAuthStrategy>());
        verifyNever(mockAuthInterceptors.authenticationType);
      });
    });
  });
}

Session _createSessionWithCapabilities(Map<CapabilityIdentifier, CapabilityProperties> capabilities) {
  return Session(
    capabilities,
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

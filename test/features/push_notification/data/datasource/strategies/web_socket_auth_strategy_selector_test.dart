import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/basic_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/no_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/ticket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/token_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy_selector.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';

import 'mocks/mock_authorization_interceptors.dart';

// Mock classes for testing
class MockWebSocketApi implements WebSocketApi {
  @override
  Future<String> getWebSocketTicket(Session session, AccountId accountId) async {
    return 'test-ticket';
  }
}

void main() {
  late MockWebSocketApi mockWebSocketApi;
  late MockAuthorizationInterceptors mockAuthInterceptors;
  late WebSocketAuthStrategySelector selector;
  late AccountId testAccountId;
  late UserName testUsername;
  late Uri testApiUrl;
  late Uri testDownloadUrl;
  late Uri testUploadUrl;
  late Uri testEventSourceUrl;
  late State testState;
  late Uri testWebSocketUri;

  setUp(() {
    mockWebSocketApi = MockWebSocketApi();
    mockAuthInterceptors = MockAuthorizationInterceptors();
    selector = WebSocketAuthStrategySelector(mockWebSocketApi, mockAuthInterceptors);

    testAccountId = AccountId(Id('test-account-id'));
    testUsername = UserName('test@example.com');
    testApiUrl = Uri.parse('https://mail.example.com/jmap');
    testDownloadUrl = Uri.parse('https://mail.example.com/download');
    testUploadUrl = Uri.parse('https://mail.example.com/upload');
    testEventSourceUrl = Uri.parse('https://mail.example.com/eventSource');
    testState = State('test-state');
    testWebSocketUri = Uri.parse('wss://mail.example.com/jmap/ws');
  });

  Session createSession({
    required Map<CapabilityIdentifier, CapabilityProperties> sessionCapabilities,
  }) {
    final account = Account(
      AccountName('Test Account'),
      true,
      false,
      {
        CapabilityIdentifier.jmapCore: CoreCapability(
          maxSizeUpload: UnsignedInt(50000000),
          maxConcurrentUpload: UnsignedInt(4),
          maxSizeRequest: UnsignedInt(10000000),
          maxConcurrentRequests: UnsignedInt(4),
          maxCallsInRequest: UnsignedInt(16),
          maxObjectsInGet: UnsignedInt(500),
          maxObjectsInSet: UnsignedInt(500),
          collationAlgorithms: {},
        ),
      },
    );

    return Session(
      sessionCapabilities,
      {testAccountId: account},
      {CapabilityIdentifier.jmapCore: testAccountId},
      testUsername,
      testApiUrl,
      testDownloadUrl,
      testUploadUrl,
      testEventSourceUrl,
      testState,
    );
  }

  group('WebSocketAuthStrategySelector', () {
    test('should return TicketAuthStrategy when jmapWebSocketTicket capability is present', () {
      final session = createSession(
        sessionCapabilities: {
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(50000000),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {},
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
          CapabilityIdentifier.jmapWebSocketTicket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
        },
      );

      final strategy = selector.selectStrategy(session);

      expect(strategy, isA<TicketAuthStrategy>());
    });

    test('should return TokenAuthStrategy when auth type is OIDC and no ticket capability', () {
      mockAuthInterceptors.setAuthenticationType(AuthenticationType.oidc);

      final session = createSession(
        sessionCapabilities: {
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(50000000),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {},
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
        },
      );

      final strategy = selector.selectStrategy(session);

      expect(strategy, isA<TokenAuthStrategy>());
    });

    test('should return BasicAuthStrategy when auth type is Basic and no ticket capability', () {
      mockAuthInterceptors.setAuthenticationType(AuthenticationType.basic);

      final session = createSession(
        sessionCapabilities: {
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(50000000),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {},
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
        },
      );

      final strategy = selector.selectStrategy(session);

      expect(strategy, isA<BasicAuthStrategy>());
    });

    test('should return NoAuthStrategy when auth type is none', () {
      mockAuthInterceptors.setAuthenticationType(AuthenticationType.none);

      final session = createSession(
        sessionCapabilities: {
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(50000000),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {},
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
        },
      );

      final strategy = selector.selectStrategy(session);

      expect(strategy, isA<NoAuthStrategy>());
    });

    test('should prioritize TicketAuthStrategy even when OIDC auth is available', () {
      mockAuthInterceptors.setAuthenticationType(AuthenticationType.oidc);

      final session = createSession(
        sessionCapabilities: {
          CapabilityIdentifier.jmapCore: CoreCapability(
            maxSizeUpload: UnsignedInt(50000000),
            maxConcurrentUpload: UnsignedInt(4),
            maxSizeRequest: UnsignedInt(10000000),
            maxConcurrentRequests: UnsignedInt(4),
            maxCallsInRequest: UnsignedInt(16),
            maxObjectsInGet: UnsignedInt(500),
            maxObjectsInSet: UnsignedInt(500),
            collationAlgorithms: {},
          ),
          CapabilityIdentifier.jmapWebSocket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
          CapabilityIdentifier.jmapWebSocketTicket: WebSocketCapability(
            url: testWebSocketUri,
            supportsPush: true,
          ),
        },
      );

      final strategy = selector.selectStrategy(session);

      // Ticket auth takes priority over OIDC when available (James server)
      expect(strategy, isA<TicketAuthStrategy>());
    });
  });
}

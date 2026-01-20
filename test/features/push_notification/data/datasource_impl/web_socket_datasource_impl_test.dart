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
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy_selector.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_capability_provider.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/web_socket_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

import '../datasource/strategies/mocks/mock_authorization_interceptors.dart';

// Mock classes
class MockWebSocketApi implements WebSocketApi {
  @override
  Future<String> getWebSocketTicket(Session session, AccountId accountId) async {
    return 'test-ticket';
  }
}

class MockExceptionThrower implements ExceptionThrower {
  @override
  dynamic throwException(dynamic error, dynamic stackTrace) {
    throw error;
  }
}

class MockAuthStrategy implements WebSocketAuthStrategy {
  final Uri uriToReturn;

  MockAuthStrategy(this.uriToReturn);

  @override
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId) async {
    return uriToReturn;
  }
}

class MockAuthStrategySelector extends WebSocketAuthStrategySelector {
  final WebSocketAuthStrategy strategyToReturn;

  MockAuthStrategySelector(this.strategyToReturn)
      : super(MockWebSocketApi(), MockAuthorizationInterceptors());

  @override
  WebSocketAuthStrategy selectStrategy(Session session) {
    return strategyToReturn;
  }
}

void main() {
  late WebSocketCapabilityProvider capabilityProvider;
  late MockExceptionThrower exceptionThrower;
  late AccountId testAccountId;
  late UserName testUsername;
  late Uri testApiUrl;
  late Uri testDownloadUrl;
  late Uri testUploadUrl;
  late Uri testEventSourceUrl;
  late State testState;
  late Uri testWebSocketUri;

  setUp(() {
    capabilityProvider = const WebSocketCapabilityProvider();
    exceptionThrower = MockExceptionThrower();
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

  group('WebSocketDatasourceImpl', () {
    group('capability validation', () {
      test('should throw WebSocketPushNotSupportedException when capability is missing', () async {
        final mockStrategy = MockAuthStrategy(testWebSocketUri);
        final strategySelector = MockAuthStrategySelector(mockStrategy);
        final datasource = WebSocketDatasourceImpl(
          capabilityProvider,
          strategySelector,
          exceptionThrower,
        );

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
          },
        );

        expect(
          () => datasource.getWebSocketChannel(session, testAccountId),
          throwsA(isA<WebSocketPushNotSupportedException>()),
        );
      });

      test('should throw WebSocketPushNotSupportedException when supportsPush is false', () async {
        final mockStrategy = MockAuthStrategy(testWebSocketUri);
        final strategySelector = MockAuthStrategySelector(mockStrategy);
        final datasource = WebSocketDatasourceImpl(
          capabilityProvider,
          strategySelector,
          exceptionThrower,
        );

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
              supportsPush: false,
            ),
          },
        );

        expect(
          () => datasource.getWebSocketChannel(session, testAccountId),
          throwsA(isA<WebSocketPushNotSupportedException>()),
        );
      });

      test('should throw WebSocketUriUnavailableException when URL is null', () async {
        final mockStrategy = MockAuthStrategy(testWebSocketUri);
        final strategySelector = MockAuthStrategySelector(mockStrategy);
        final datasource = WebSocketDatasourceImpl(
          capabilityProvider,
          strategySelector,
          exceptionThrower,
        );

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
              url: null,
              supportsPush: true,
            ),
          },
        );

        expect(
          () => datasource.getWebSocketChannel(session, testAccountId),
          throwsA(isA<WebSocketUriUnavailableException>()),
        );
      });
    });

    group('integration scenarios', () {
      test('should work with Stalwart-style session (supportsPush null)', () async {
        final mockStrategy = MockAuthStrategy(
          Uri.parse('wss://mail.example.com/jmap/ws?access_token=token'),
        );
        final strategySelector = MockAuthStrategySelector(mockStrategy);
        final datasource = WebSocketDatasourceImpl(
          capabilityProvider,
          strategySelector,
          exceptionThrower,
        );

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
              supportsPush: null, // Stalwart-style
            ),
          },
        );

        // This should not throw - supportsPush null is treated as "supports push"
        // Note: Actual WebSocket connection will fail in test environment,
        // but capability validation should pass
        try {
          await datasource.getWebSocketChannel(session, testAccountId);
        } catch (e) {
          // Expected to fail at actual WebSocket connection, not at validation
          expect(e, isNot(isA<WebSocketPushNotSupportedException>()));
          expect(e, isNot(isA<WebSocketUriUnavailableException>()));
        }
      });

      test('should work with James-style session (ticket capability)', () async {
        final mockStrategy = MockAuthStrategy(
          Uri.parse('wss://mail.example.com/jmap/ws?ticket=abc123'),
        );
        final strategySelector = MockAuthStrategySelector(mockStrategy);
        final datasource = WebSocketDatasourceImpl(
          capabilityProvider,
          strategySelector,
          exceptionThrower,
        );

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

        // This should not throw at capability validation
        try {
          await datasource.getWebSocketChannel(session, testAccountId);
        } catch (e) {
          // Expected to fail at actual WebSocket connection, not at validation
          expect(e, isNot(isA<WebSocketPushNotSupportedException>()));
          expect(e, isNot(isA<WebSocketUriUnavailableException>()));
        }
      });
    });
  });
}

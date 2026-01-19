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
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/basic_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/no_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/ticket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/token_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';

import 'mocks/mock_authorization_interceptors.dart';

// Mock classes for testing
class MockWebSocketApi implements WebSocketApi {
  String? ticketToReturn;
  Exception? exceptionToThrow;

  @override
  Future<String> getWebSocketTicket(Session session, AccountId accountId) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return ticketToReturn ?? 'test-ticket-123';
  }
}

void main() {
  late AccountId testAccountId;
  late UserName testUsername;
  late Uri testApiUrl;
  late Uri testDownloadUrl;
  late Uri testUploadUrl;
  late Uri testEventSourceUrl;
  late State testState;
  late Uri testWebSocketUri;

  setUp(() {
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

  group('TicketAuthStrategy', () {
    late MockWebSocketApi mockWebSocketApi;
    late TicketAuthStrategy strategy;

    setUp(() {
      mockWebSocketApi = MockWebSocketApi();
      strategy = TicketAuthStrategy(mockWebSocketApi);
    });

    test('should append ticket as query parameter', () async {
      mockWebSocketApi.ticketToReturn = 'my-secret-ticket';

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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(result.queryParameters['ticket'], equals('my-secret-ticket'));
      expect(result.scheme, equals('wss'));
      expect(result.host, equals('mail.example.com'));
    });

    test('should propagate exception when ticket fetch fails', () async {
      mockWebSocketApi.exceptionToThrow = Exception('Network error');

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
        () => strategy.buildConnectionUri(testWebSocketUri, session, testAccountId),
        throwsException,
      );
    });
  });

  group('TokenAuthStrategy', () {
    late MockAuthorizationInterceptors mockAuthInterceptors;
    late TokenAuthStrategy strategy;

    setUp(() {
      mockAuthInterceptors = MockAuthorizationInterceptors();
      strategy = TokenAuthStrategy(mockAuthInterceptors);
    });

    test('should append access_token when OIDC token is available', () async {
      mockAuthInterceptors.setCurrentToken('oauth-access-token-123');

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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(result.queryParameters['access_token'], equals('oauth-access-token-123'));
    });

    test('should return base URI when no token is available', () async {
      mockAuthInterceptors.setCurrentToken(null);

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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(result.queryParameters.containsKey('access_token'), isFalse);
      expect(result, equals(testWebSocketUri));
    });

    test('should return base URI when token is empty', () async {
      mockAuthInterceptors.setCurrentToken('');

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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(result.queryParameters.containsKey('access_token'), isFalse);
    });
  });

  group('BasicAuthStrategy', () {
    late MockAuthorizationInterceptors mockAuthInterceptors;
    late BasicAuthStrategy strategy;

    setUp(() {
      mockAuthInterceptors = MockAuthorizationInterceptors();
      strategy = BasicAuthStrategy(mockAuthInterceptors);
    });

    test('should append authorization when basic credentials are available', () async {
      mockAuthInterceptors.setBasicAuthCredentials('dXNlcjpwYXNzd29yZA==');

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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(
        result.queryParameters['authorization'],
        equals('Basic dXNlcjpwYXNzd29yZA=='),
      );
    });

    test('should return base URI when no basic credentials are available', () async {
      mockAuthInterceptors.setBasicAuthCredentials(null);

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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(result.queryParameters.containsKey('authorization'), isFalse);
      expect(result, equals(testWebSocketUri));
    });
  });

  group('NoAuthStrategy', () {
    late NoAuthStrategy strategy;

    setUp(() {
      strategy = const NoAuthStrategy();
    });

    test('should return base URI unchanged', () async {
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

      final result = await strategy.buildConnectionUri(
        testWebSocketUri,
        session,
        testAccountId,
      );

      expect(result, equals(testWebSocketUri));
      expect(result.queryParameters.isEmpty, isTrue);
    });
  });
}

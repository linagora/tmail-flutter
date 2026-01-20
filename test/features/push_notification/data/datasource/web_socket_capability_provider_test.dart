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
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_capability_provider.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';

void main() {
  late WebSocketCapabilityProvider provider;
  late AccountId testAccountId;
  late UserName testUsername;
  late Uri testApiUrl;
  late Uri testDownloadUrl;
  late Uri testUploadUrl;
  late Uri testEventSourceUrl;
  late State testState;
  late Uri testWebSocketUri;

  setUp(() {
    provider = const WebSocketCapabilityProvider();
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

  group('WebSocketCapabilityProvider', () {
    group('getCapability', () {
      test('should return WebSocketCapability when present', () {
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

        final capability = provider.getCapability(session);

        expect(capability, isNotNull);
        expect(capability?.url, equals(testWebSocketUri));
        expect(capability?.supportsPush, isTrue);
      });

      test('should return null when WebSocket capability is not present', () {
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

        final capability = provider.getCapability(session);

        expect(capability, isNull);
      });
    });

    group('hasCapability', () {
      test('should return true when WebSocket capability is present', () {
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

        expect(provider.hasCapability(session), isTrue);
      });

      test('should return false when WebSocket capability is not present', () {
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

        expect(provider.hasCapability(session), isFalse);
      });
    });

    group('supportsPush', () {
      test('should return true when supportsPush is true', () {
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

        expect(provider.supportsPush(session), isTrue);
      });

      test('should return false when supportsPush is explicitly false', () {
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

        expect(provider.supportsPush(session), isFalse);
      });

      test('should return true when supportsPush is null (Stalwart-style)', () {
        // Stalwart servers may not include supportsPush, treating null as "supports push"
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
              supportsPush: null,
            ),
          },
        );

        expect(provider.supportsPush(session), isTrue);
      });
    });

    group('validateCapability', () {
      test('should not throw when WebSocket capability is present with supportsPush true', () {
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

        expect(() => provider.validateCapability(session), returnsNormally);
      });

      test('should throw WebSocketPushNotSupportedException when capability is missing', () {
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
          () => provider.validateCapability(session),
          throwsA(isA<WebSocketPushNotSupportedException>()),
        );
      });

      test('should throw WebSocketPushNotSupportedException when supportsPush is false', () {
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
          () => provider.validateCapability(session),
          throwsA(isA<WebSocketPushNotSupportedException>()),
        );
      });

      test('should not throw when supportsPush is null (Stalwart-style)', () {
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
              supportsPush: null,
            ),
          },
        );

        expect(() => provider.validateCapability(session), returnsNormally);
      });
    });

    group('getWebSocketUri', () {
      test('should return URI when WebSocket capability has URL', () {
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

        final uri = provider.getWebSocketUri(session);

        expect(uri, equals(testWebSocketUri));
      });

      test('should throw WebSocketUriUnavailableException when URL is null', () {
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
          () => provider.getWebSocketUri(session),
          throwsA(isA<WebSocketUriUnavailableException>()),
        );
      });

      test('should throw WebSocketUriUnavailableException when capability is missing', () {
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
          () => provider.getWebSocketUri(session),
          throwsA(isA<WebSocketUriUnavailableException>()),
        );
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';

void main() {
  group('WebSocket Capability Detection Tests', () {
    late AccountId testAccountId;
    late UserName testUsername;
    late Uri testApiUrl;
    late Uri testDownloadUrl;
    late Uri testUploadUrl;
    late Uri testEventSourceUrl;
    late State testState;

    setUp(() {
      testAccountId = AccountId(Id('test-account-id'));
      testUsername = UserName('test@example.com');
      testApiUrl = Uri.parse('https://mail.example.com/jmap');
      testDownloadUrl = Uri.parse('https://mail.example.com/download');
      testUploadUrl = Uri.parse('https://mail.example.com/upload');
      testEventSourceUrl = Uri.parse('https://mail.example.com/eventSource');
      testState = State('test-state');
    });

    Session createSession({
      required Map<CapabilityIdentifier, CapabilityProperties> sessionCapabilities,
      Map<CapabilityIdentifier, CapabilityProperties>? accountCapabilities,
    }) {
      final account = Account(
        AccountName('Test Account'),
        true,
        false,
        accountCapabilities ?? {
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
          CapabilityIdentifier.jmapMail: MailCapability(
            maxMailboxesPerEmail: null,
            maxMailboxDepth: null,
            maxSizeMailboxName: UnsignedInt(256),
            maxSizeAttachmentsPerEmail: UnsignedInt(50000000),
            emailQuerySortOptions: {'receivedAt', 'sentAt'},
            mayCreateTopLevelMailbox: true,
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

    group('Session-level WebSocket capability detection', () {
      test('should detect WebSocket capability at session level (Stalwart-style)', () {
        // Stalwart and other RFC 8887-compliant servers advertise WebSocket
        // at the session level, not account level
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
              url: Uri.parse('wss://mail.example.com/jmap/ws'),
              supportsPush: true,
            ),
          },
        );

        // This is the key assertion: WebSocket capability should be at session level
        final hasWebSocket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
        expect(hasWebSocket, isTrue, reason: 'WebSocket capability should be detected at session level');

        // Verify the WebSocket capability properties
        final wsCapability = session.capabilities[CapabilityIdentifier.jmapWebSocket] as WebSocketCapability?;
        expect(wsCapability, isNotNull);
        expect(wsCapability?.supportsPush, isTrue);
        expect(wsCapability?.url?.toString(), equals('wss://mail.example.com/jmap/ws'));
      });

      test('should NOT detect WebSocket when only core capability is present', () {
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

        final hasWebSocket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
        expect(hasWebSocket, isFalse, reason: 'WebSocket capability should not be detected when not present');
      });

      test('should detect James-style ticket authentication capability at session level', () {
        // Apache James uses a proprietary ticket authentication for WebSocket
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
              url: Uri.parse('wss://mail.example.com/jmap/ws'),
              supportsPush: true,
            ),
            CapabilityIdentifier.jmapWebSocketTicket: WebSocketCapability(
              url: Uri.parse('wss://mail.example.com/jmap/ws'),
              supportsPush: true,
            ),
          },
        );

        final hasWebSocket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
        final hasTicket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocketTicket);

        expect(hasWebSocket, isTrue);
        expect(hasTicket, isTrue, reason: 'James-style ticket capability should be detected');
      });

      test('should detect WebSocket without ticket for non-James servers (Stalwart)', () {
        // Stalwart does not use James-style ticket authentication
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
              url: Uri.parse('wss://mail.stalwart.example.com/jmap/ws'),
              supportsPush: true,
            ),
          },
        );

        final hasWebSocket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
        final hasTicket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocketTicket);

        expect(hasWebSocket, isTrue, reason: 'Stalwart-style WebSocket should be detected');
        expect(hasTicket, isFalse, reason: 'Stalwart does not use James-style ticket auth');
      });

      test('should detect when supportsPush is false', () {
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
              url: Uri.parse('wss://mail.example.com/jmap/ws'),
              supportsPush: false,  // Push is disabled
            ),
          },
        );

        final hasWebSocket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
        expect(hasWebSocket, isTrue, reason: 'WebSocket capability exists');

        final wsCapability = session.capabilities[CapabilityIdentifier.jmapWebSocket] as WebSocketCapability?;
        expect(wsCapability?.supportsPush, isFalse, reason: 'supportsPush should be false');
      });
    });

    group('Capability identifier URN verification', () {
      test('jmapWebSocket should use standard IETF URN', () {
        expect(
          CapabilityIdentifier.jmapWebSocket.value.toString(),
          equals('urn:ietf:params:jmap:websocket'),
          reason: 'WebSocket capability should use RFC 8887 standard URN',
        );
      });

      test('jmapWebSocketTicket should use Linagora/James-specific URN', () {
        expect(
          CapabilityIdentifier.jmapWebSocketTicket.value.toString(),
          equals('com:linagora:params:jmap:ws:ticket'),
          reason: 'Ticket capability should use James-specific URN',
        );
      });
    });
  });
}

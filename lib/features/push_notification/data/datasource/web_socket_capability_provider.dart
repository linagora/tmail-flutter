import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';

/// Provides WebSocket capability information from JMAP sessions.
///
/// JMAP advertises WebSocket support at the session level (not account level)
/// via the `urn:ietf:params:jmap:websocket` capability identifier.
///
/// This class consolidates capability access logic to avoid duplication
/// and ensures consistent handling of capability detection across the codebase.
class WebSocketCapabilityProvider {
  const WebSocketCapabilityProvider();

  /// Gets the WebSocket capability from the session.
  ///
  /// Returns null if the capability is not present.
  WebSocketCapability? getCapability(Session session) {
    return session.capabilities[CapabilityIdentifier.jmapWebSocket] as WebSocketCapability?;
  }

  /// Checks if WebSocket capability is present in the session.
  bool hasCapability(Session session) {
    return session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
  }

  /// Checks if WebSocket push is supported.
  ///
  /// Per JMAP specification, some servers may advertise WebSocket capability
  /// but not support push. We treat null as "supports push" since the
  /// capability exists - only explicit `false` disables push.
  bool supportsPush(Session session) {
    final capability = getCapability(session);
    // If capability exists, allow push unless supportsPush is explicitly false.
    // Some servers (like Stalwart) may not include supportsPush in the response,
    // defaulting to null. We treat null as "supports push" since the capability exists.
    return capability?.supportsPush != false;
  }

  /// Validates that WebSocket capability is present and supports push.
  ///
  /// Throws [WebSocketPushNotSupportedException] if:
  /// - WebSocket capability is not present
  /// - WebSocket capability exists but supportsPush is explicitly false
  void validateCapability(Session session) {
    final hasWebSocket = hasCapability(session);
    log('WebSocketCapabilityProvider::validateCapability: hasWebSocket=$hasWebSocket');

    if (!hasWebSocket) {
      throw WebSocketPushNotSupportedException();
    }

    final capability = getCapability(session);
    log('WebSocketCapabilityProvider::validateCapability: supportsPush=${capability?.supportsPush}');

    if (capability?.supportsPush == false) {
      throw WebSocketPushNotSupportedException();
    }
  }

  /// Gets the WebSocket URL from the session capability.
  ///
  /// Throws [WebSocketUriUnavailableException] if the URL is not available.
  Uri getWebSocketUri(Session session) {
    final capability = getCapability(session);
    final url = capability?.url;

    log('WebSocketCapabilityProvider::getWebSocketUri: url=${url?.toString()}');

    if (url == null) {
      throw WebSocketUriUnavailableException();
    }

    return url;
  }
}

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

/// Abstract strategy for WebSocket authentication.
///
/// Different JMAP servers use different authentication mechanisms for WebSocket
/// connections. This strategy pattern allows the application to support multiple
/// authentication methods transparently.
///
/// Implementations:
/// - [TicketAuthStrategy]: For James servers using proprietary ticket-based auth
/// - [TokenAuthStrategy]: For OIDC authentication (Stalwart, standard JMAP)
/// - [BasicAuthStrategy]: For Basic authentication
/// - [NoAuthStrategy]: For connections without authentication
abstract class WebSocketAuthStrategy {
  /// Builds the WebSocket connection URI with authentication credentials.
  ///
  /// Takes the [baseUri] (WebSocket URL from JMAP capabilities), the [session]
  /// for server-specific capability detection, and the [accountId] for
  /// account-specific operations.
  ///
  /// Returns the complete URI with authentication query parameters.
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId);
}

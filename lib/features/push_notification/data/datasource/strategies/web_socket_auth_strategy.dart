import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

/// Abstract strategy for WebSocket authentication.
///
/// ## Background
///
/// Browser-based JMAP clients face a fundamental limitation: the WebSocket API
/// cannot set custom HTTP headers like `Authorization: Bearer <token>`.
/// This makes standard RFC 8887 authentication impossible directly from browsers.
///
/// ## Solution: Strategy Pattern
///
/// Different JMAP servers use different authentication mechanisms for WebSocket
/// connections. This strategy pattern allows the application to support multiple
/// authentication methods transparently:
///
/// ### Implementations
///
/// - [TicketAuthStrategy]: For James servers using proprietary ticket-based auth.
///   The server provides a `com:linagora:params:jmap:ws:ticket` capability and
///   issues short-lived tickets via POST /jmap/ws/ticket.
///
/// - [TokenAuthStrategy]: For OIDC authentication (Stalwart, standard JMAP).
///   Passes `access_token` as query parameter; requires reverse proxy to convert
///   to `Authorization: Bearer` header.
///
/// - [BasicAuthStrategy]: For Basic authentication.
///   Passes `authorization` as query parameter; requires reverse proxy.
///
/// - [NoAuthStrategy]: Fallback for connections without authentication.
///
/// ## Reverse Proxy Requirement
///
/// For non-ticket strategies, a reverse proxy (nginx, Caddy, etc.) must:
/// 1. Extract the auth token from the query string
/// 2. URL-decode it (tokens contain base64 chars)
/// 3. Set it as the `Authorization` header
/// 4. Forward the WebSocket upgrade request
///
/// See: docs/websocket-auth-proxy.md for configuration examples.
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

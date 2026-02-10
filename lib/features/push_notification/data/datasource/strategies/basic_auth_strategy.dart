import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';

/// WebSocket authentication strategy for HTTP Basic authentication.
///
/// Used by JMAP servers that authenticate via HTTP Basic authentication
/// (username:password encoded as base64).
///
/// ## Browser WebSocket Authentication Limitation
///
/// The browser WebSocket API cannot set custom HTTP headers.
/// This strategy passes the Basic auth credentials as a query parameter
/// (`?authorization=Basic ...`).
///
/// ## Reverse Proxy Requirement
///
/// The server infrastructure must include a reverse proxy that:
///
/// 1. Extracts the `authorization` value from the query string
/// 2. URL-decodes it
/// 3. Sets it as the `Authorization` header
/// 4. Forwards the WebSocket upgrade request to the mail server
///
/// ## Security Considerations
///
/// - Basic auth credentials appear in URL; ensure logs are protected
/// - Use HTTPS/WSS exclusively to prevent credential interception
/// - Consider using OIDC instead of Basic auth for better security
///
/// See: docs/websocket-auth-proxy.md for reverse proxy configuration examples.
class BasicAuthStrategy implements WebSocketAuthStrategy {
  final AuthorizationInterceptors _authInterceptors;

  const BasicAuthStrategy(this._authInterceptors);

  @override
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId) async {
    final basicAuth = _authInterceptors.basicAuthCredentials;
    log('BasicAuthStrategy::buildConnectionUri: Basic auth available=${basicAuth != null}');

    if (basicAuth != null && basicAuth.isNotEmpty) {
      return baseUri.replace(queryParameters: {
        ...baseUri.queryParameters,
        'authorization': 'Basic $basicAuth',
      });
    }

    logWarning('BasicAuthStrategy::buildConnectionUri: No basic auth credentials available, connecting without auth');
    return baseUri;
  }
}

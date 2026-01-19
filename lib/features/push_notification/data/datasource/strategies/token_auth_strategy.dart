import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';

/// WebSocket authentication strategy for OIDC/OAuth2 authentication.
///
/// Used by RFC 8887-compliant JMAP servers like Stalwart that don't support
/// James-style ticket authentication.
///
/// ## Browser WebSocket Authentication Limitation
///
/// The browser WebSocket API cannot set custom HTTP headers (like `Authorization`).
/// Per RFC 8887, JMAP WebSocket requires `Authorization: Bearer <token>` header.
///
/// ## Workaround
///
/// This strategy passes the access token as a query parameter (`?access_token=...`).
/// The server infrastructure must include a reverse proxy that:
/// 1. Extracts the `access_token` from the query string
/// 2. URL-decodes it (tokens contain base64 chars like `+`, `/`, `=`)
/// 3. Sets it as `Authorization: Bearer <token>` header
/// 4. Forwards the WebSocket upgrade request to the mail server
///
/// See: docs/websocket-auth-proxy.md for full setup instructions.
class TokenAuthStrategy implements WebSocketAuthStrategy {
  final AuthorizationInterceptors _authInterceptors;

  const TokenAuthStrategy(this._authInterceptors);

  @override
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId) async {
    final token = _authInterceptors.currentToken;
    log('TokenAuthStrategy::buildConnectionUri: OIDC token available=${token != null}');

    if (token != null && token.isNotEmpty) {
      return baseUri.replace(queryParameters: {
        ...baseUri.queryParameters,
        'access_token': token,
      });
    }

    logWarning('TokenAuthStrategy::buildConnectionUri: No OIDC token available, connecting without auth');
    return baseUri;
  }
}

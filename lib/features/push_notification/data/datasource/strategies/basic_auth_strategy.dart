import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';

/// WebSocket authentication strategy for Basic authentication.
///
/// Used by JMAP servers that authenticate via HTTP Basic authentication.
///
/// ## Browser WebSocket Authentication Limitation
///
/// The browser WebSocket API cannot set custom HTTP headers.
/// This strategy passes the Basic auth credentials as a query parameter
/// (`?authorization=Basic ...`) which must be converted to a proper header
/// by a reverse proxy.
///
/// See: docs/websocket-auth-proxy.md for full setup instructions.
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

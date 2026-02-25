import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';

/// WebSocket authentication strategy for connections without authentication.
///
/// Used as a fallback when:
/// - No authentication credentials are available
/// - The authentication type is explicitly set to `none`
/// - Server allows unauthenticated WebSocket connections
///
/// ## Usage
///
/// This strategy simply returns the base URI without modification.
/// The [WebSocketAuthStrategySelector] selects this strategy when
/// [AuthenticationType.none] is detected.
///
/// ## Warning
///
/// Connecting without authentication typically results in connection failure
/// unless the server explicitly allows anonymous WebSocket connections.
class NoAuthStrategy implements WebSocketAuthStrategy {
  const NoAuthStrategy();

  @override
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId) async {
    logWarning('NoAuthStrategy::buildConnectionUri: Connecting without authentication');
    return baseUri;
  }
}

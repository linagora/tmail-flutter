import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';

/// WebSocket authentication strategy for Apache James servers.
///
/// James servers use a proprietary ticket-based authentication mechanism that
/// solves the browser WebSocket header limitation elegantly on the server side:
///
/// ## Authentication Flow
///
/// 1. Client requests a short-lived ticket via `POST /jmap/ws/ticket`
///    with standard Bearer token authentication
/// 2. Server returns a one-time-use ticket (typically valid for ~60 seconds)
/// 3. Client connects to WebSocket with `?ticket=<ticket>` query parameter
/// 4. Server validates ticket and establishes authenticated connection
///
/// ## Capability Detection
///
/// This approach is advertised via the `com:linagora:params:jmap:ws:ticket`
/// capability identifier in the JMAP session. The [WebSocketAuthStrategySelector]
/// automatically detects this capability and selects this strategy.
///
/// ## Advantages
///
/// - No reverse proxy configuration required
/// - Secure: tickets are short-lived and single-use
/// - Server handles all authentication logic
///
/// ## Limitations
///
/// - James-specific (proprietary extension to JMAP)
/// - Requires additional HTTP request before WebSocket connection
class TicketAuthStrategy implements WebSocketAuthStrategy {
  final WebSocketApi _webSocketApi;

  const TicketAuthStrategy(this._webSocketApi);

  @override
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId) async {
    log('TicketAuthStrategy::buildConnectionUri: Fetching ticket from James server');

    final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
    final connectionUri = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        'ticket': webSocketTicket,
      },
    );

    log('TicketAuthStrategy::buildConnectionUri: Ticket obtained successfully');
    return connectionUri;
  }
}

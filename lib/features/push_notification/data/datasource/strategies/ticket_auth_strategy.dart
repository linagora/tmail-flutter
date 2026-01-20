import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';

/// WebSocket authentication strategy for Apache James servers.
///
/// James servers use a proprietary ticket-based authentication mechanism:
/// 1. Client requests a short-lived ticket via POST /jmap/ws/ticket
/// 2. Server returns a one-time-use ticket
/// 3. Client connects to WebSocket with ?ticket=<ticket> query parameter
///
/// This approach is advertised via the `com:linagora:params:jmap:ws:ticket`
/// capability identifier in the JMAP session.
class TicketAuthStrategy implements WebSocketAuthStrategy {
  final WebSocketApi _webSocketApi;

  const TicketAuthStrategy(this._webSocketApi);

  @override
  Future<Uri> buildConnectionUri(Uri baseUri, Session session, AccountId accountId) async {
    log('TicketAuthStrategy::buildConnectionUri: Fetching ticket from James server');
    final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
    final connectionUri = Uri.parse('${baseUri.toString()}?ticket=$webSocketTicket');
    log('TicketAuthStrategy::buildConnectionUri: Ticket obtained successfully');
    return connectionUri;
  }
}

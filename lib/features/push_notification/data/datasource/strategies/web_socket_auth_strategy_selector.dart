import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/basic_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/no_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/ticket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/token_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';

/// Selects the appropriate WebSocket authentication strategy based on
/// server capabilities and current authentication type.
///
/// ## Strategy Selection Algorithm
///
/// 1. **Check for James ticket capability**: If the session advertises
///    `com:linagora:params:jmap:ws:ticket`, use [TicketAuthStrategy].
///    This is the most seamless option as it requires no proxy configuration.
///
/// 2. **Fall back to standard authentication**: Based on [AuthorizationInterceptors]:
///    - OIDC → [TokenAuthStrategy] (requires reverse proxy)
///    - Basic → [BasicAuthStrategy] (requires reverse proxy)
///    - None → [NoAuthStrategy] (fallback, likely to fail)
///
/// ## Server Compatibility
///
/// | Server    | Strategy        | Proxy Required |
/// |-----------|-----------------|----------------|
/// | James     | Ticket          | No             |
/// | Stalwart  | Token (OIDC)    | Yes            |
/// | Cyrus     | Token/Basic     | Yes            |
/// | Other     | Token/Basic     | Yes            |
///
/// ## Usage
///
/// ```dart
/// final selector = WebSocketAuthStrategySelector(webSocketApi, authInterceptors);
/// final strategy = selector.selectStrategy(session);
/// final uri = await strategy.buildConnectionUri(baseUri, session, accountId);
/// ```
class WebSocketAuthStrategySelector {
  final WebSocketApi _webSocketApi;
  final AuthorizationInterceptors _authInterceptors;

  const WebSocketAuthStrategySelector(this._webSocketApi, this._authInterceptors);

  /// Selects the appropriate authentication strategy based on session capabilities.
  ///
  /// Priority:
  /// 1. James ticket auth (if `jmapWebSocketTicket` capability is present)
  /// 2. OIDC token auth (if authentication type is OIDC)
  /// 3. Basic auth (if authentication type is Basic)
  /// 4. No auth (fallback)
  WebSocketAuthStrategy selectStrategy(Session session) {
    // Check for James-style ticket authentication (proprietary capability)
    final hasTicketAuth = session.capabilities.containsKey(
      CapabilityIdentifier.jmapWebSocketTicket,
    );

    if (hasTicketAuth) {
      log('WebSocketAuthStrategySelector::selectStrategy: Using ticket auth (James server)');
      return TicketAuthStrategy(_webSocketApi);
    }

    // Fall back to standard authentication based on current auth type
    final authType = _authInterceptors.authenticationType;
    log('WebSocketAuthStrategySelector::selectStrategy: No ticket capability, using authType=$authType');

    return switch (authType) {
      AuthenticationType.oidc => TokenAuthStrategy(_authInterceptors),
      AuthenticationType.basic => BasicAuthStrategy(_authInterceptors),
      AuthenticationType.none => const NoAuthStrategy(),
    };
  }
}

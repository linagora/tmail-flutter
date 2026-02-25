import 'dart:async';

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/strategies/web_socket_auth_strategy_selector.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_capability_provider.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/utils/web_socket_uri_builder.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Implementation of [WebSocketDatasource] that connects to JMAP WebSocket servers.
///
/// ## Multi-Server Compatibility
///
/// This implementation supports multiple JMAP server implementations via the
/// Strategy pattern. Authentication is handled by [WebSocketAuthStrategySelector]
/// which automatically detects the appropriate authentication method:
///
/// | Server    | Strategy Used   | Proxy Required |
/// |-----------|-----------------|----------------|
/// | James     | Ticket-based    | No             |
/// | Stalwart  | OIDC Token      | Yes            |
/// | Cyrus     | Token/Basic     | Yes            |
/// | Other     | Auto-detected   | Depends        |
///
/// ## Connection Flow
///
/// 1. Validate WebSocket capability exists in JMAP session
/// 2. Extract WebSocket URI from session capability
/// 3. Select appropriate authentication strategy
/// 4. Build connection URI with authentication credentials
/// 5. Establish WebSocket connection with JMAP protocol
///
/// ## Browser Authentication Limitation
///
/// Browsers cannot set custom HTTP headers on WebSocket connections.
/// For non-James servers, a reverse proxy is required to convert query
/// parameters to Authorization headers.
///
/// See: docs/websocket-auth-proxy.md for proxy configuration.
class WebSocketDatasourceImpl implements WebSocketDatasource {
  final WebSocketCapabilityProvider _capabilityProvider;
  final WebSocketAuthStrategySelector _strategySelector;
  final ExceptionThrower _exceptionThrower;

  const WebSocketDatasourceImpl(
    this._capabilityProvider,
    this._strategySelector,
    this._exceptionThrower,
  );

  @override
  Future<WebSocketChannel> getWebSocketChannel(Session session, AccountId accountId) {
    return Future.sync(() async {
      // Step 1: Validate WebSocket capability is present and supports push
      _capabilityProvider.validateCapability(session);

      // Step 2: Get WebSocket URI from session capability
      final webSocketUri = _capabilityProvider.getWebSocketUri(session);

      // Step 3: Select and execute authentication strategy
      final strategy = _strategySelector.selectStrategy(session);
      final connectionUri = await strategy.buildConnectionUri(
        webSocketUri.ensureWebSocketUri(),
        session,
        accountId,
      );

      // Log connection URI with sensitive params redacted for security
      log('WebSocketDatasourceImpl::getWebSocketChannel: Connecting to ${WebSocketUriBuilder.redactSensitiveParams(connectionUri)}');

      // Step 4: Establish WebSocket connection with JMAP protocol
      final webSocketChannel = WebSocketChannel.connect(
        connectionUri,
        protocols: ["jmap"],
      );

      await webSocketChannel.ready;
      log('WebSocketDatasourceImpl::getWebSocketChannel: WebSocket connected successfully');

      return webSocketChannel;
    }).catchError(_exceptionThrower.throwException);
  }
}

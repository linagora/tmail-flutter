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
/// Supports multiple authentication strategies via [WebSocketAuthStrategySelector]:
/// - James ticket-based authentication
/// - OIDC/OAuth2 token authentication
/// - Basic authentication
///
/// See: docs/websocket-auth-proxy.md for proxy setup required for non-ticket auth.
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
      // Validate WebSocket capability is present and supports push
      _capabilityProvider.validateCapability(session);

      // Get WebSocket URI from session capability
      final webSocketUri = _capabilityProvider.getWebSocketUri(session);

      // Select and execute authentication strategy
      final strategy = _strategySelector.selectStrategy(session);
      final connectionUri = await strategy.buildConnectionUri(
        webSocketUri.ensureWebSocketUri(),
        session,
        accountId,
      );

      log('WebSocketDatasourceImpl::getWebSocketChannel: Connecting to ${WebSocketUriBuilder.redactSensitiveParams(connectionUri)}');

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

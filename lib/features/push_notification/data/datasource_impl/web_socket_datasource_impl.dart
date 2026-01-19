
import 'dart:async';

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDatasourceImpl implements WebSocketDatasource {
  final WebSocketApi _webSocketApi;
  final ExceptionThrower _exceptionThrower;

  const WebSocketDatasourceImpl(this._webSocketApi, this._exceptionThrower);

  @override
  Future<WebSocketChannel> getWebSocketChannel(Session session, AccountId accountId) {
    return Future.sync(() async {
      _verifyWebSocketCapabilities(session, accountId);
      final webSocketUri = _getWebSocketUri(session, accountId);

      // Check if server supports James-style ticket authentication (session-level capability)
      final hasTicketAuth = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocketTicket);
      log('WebSocketDatasourceImpl::getWebSocketChannel: hasTicketAuth=$hasTicketAuth', webConsoleEnabled: true);

      Uri connectionUri;
      if (hasTicketAuth) {
        // Use James ticket-based authentication
        final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
        connectionUri = Uri.parse('${webSocketUri.ensureWebSocketUri().toString()}?ticket=$webSocketTicket');
        log('WebSocketDatasourceImpl::getWebSocketChannel: Using ticket auth', webConsoleEnabled: true);
      } else {
        // Use standard token/basic authentication (for Stalwart and other JMAP servers)
        connectionUri = await _buildAuthUri(webSocketUri);
        log('WebSocketDatasourceImpl::getWebSocketChannel: Using standard auth', webConsoleEnabled: true);
      }

      log('WebSocketDatasourceImpl::getWebSocketChannel: Connecting to ${_redactSensitiveParams(connectionUri)}', webConsoleEnabled: true);
      final webSocketChannel = WebSocketChannel.connect(
        connectionUri,
        protocols: ["jmap"],
      );

      await webSocketChannel.ready;
      log('WebSocketDatasourceImpl::getWebSocketChannel: WebSocket connected successfully', webConsoleEnabled: true);

      return webSocketChannel;
    }).catchError(_exceptionThrower.throwException);
  }

  /// Builds the WebSocket URI with authentication for non-James servers (e.g., Stalwart).
  ///
  /// ## Browser WebSocket Authentication Limitation
  ///
  /// The browser WebSocket API cannot set custom HTTP headers (like `Authorization`).
  /// Per RFC 8887, JMAP WebSocket requires `Authorization: Bearer <token>` header.
  ///
  /// ## Workaround
  ///
  /// This method passes the access token as a query parameter (`?access_token=...`).
  /// The server infrastructure must include a reverse proxy that:
  /// 1. Extracts the `access_token` from the query string
  /// 2. URL-decodes it (tokens contain base64 chars like `+`, `/`, `=`)
  /// 3. Sets it as `Authorization: Bearer <token>` header
  /// 4. Forwards the WebSocket upgrade request to the mail server
  ///
  /// Example nginx/OpenResty configuration:
  /// ```nginx
  /// location /jmap/ws {
  ///     set_by_lua_block $auth_header {
  ///         local token = ngx.var.arg_access_token
  ///         if token and token ~= "" then
  ///             return "Bearer " .. ngx.unescape_uri(token)
  ///         end
  ///         return ""
  ///     }
  ///     proxy_set_header Authorization $auth_header;
  ///     proxy_http_version 1.1;
  ///     proxy_set_header Upgrade $http_upgrade;
  ///     proxy_set_header Connection "Upgrade";  # Case-sensitive!
  ///     proxy_pass http://mail-server:8080;
  /// }
  /// ```
  ///
  /// See: docs/websocket-auth-proxy.md for full setup instructions.
  Future<Uri> _buildAuthUri(Uri webSocketUri) async {
    final wsUri = webSocketUri.ensureWebSocketUri();

    try {
      final authInterceptors = Get.find<AuthorizationInterceptors>();
      final authType = authInterceptors.authenticationType;
      log('WebSocketDatasourceImpl::_buildAuthUri: authType=$authType', webConsoleEnabled: true);

      if (authType == AuthenticationType.oidc) {
        // Pass access token as query parameter - requires server-side proxy to convert to header
        final token = authInterceptors.currentToken;
        log('WebSocketDatasourceImpl::_buildAuthUri: OIDC token available=${token != null}', webConsoleEnabled: true);
        if (token != null && token.isNotEmpty) {
          return wsUri.replace(queryParameters: {
            ...wsUri.queryParameters,
            'access_token': token,
          });
        }
      } else if (authType == AuthenticationType.basic) {
        // Pass basic auth as query parameter - requires server-side proxy to convert to header
        final basicAuth = authInterceptors.basicAuthCredentials;
        log('WebSocketDatasourceImpl::_buildAuthUri: Basic auth available=${basicAuth != null}', webConsoleEnabled: true);
        if (basicAuth != null && basicAuth.isNotEmpty) {
          return wsUri.replace(queryParameters: {
            ...wsUri.queryParameters,
            'authorization': 'Basic $basicAuth',
          });
        }
      }
      logWarning('WebSocketDatasourceImpl::_buildAuthUri: No auth credentials available, connecting without auth');
    } catch (e) {
      log('WebSocketDatasourceImpl::_buildAuthUri: Error getting auth: $e', webConsoleEnabled: true);
    }

    return wsUri;
  }

  void _verifyWebSocketCapabilities(Session session, AccountId accountId) {
    // WebSocket is a session-level capability in JMAP, not account-level
    // Check session.capabilities directly (not getCapabilityProperties which doesn't work for session-level)
    final hasWebSocket = session.capabilities.containsKey(CapabilityIdentifier.jmapWebSocket);
    log('WebSocketDatasourceImpl::_verifyWebSocketCapabilities: hasWebSocket=$hasWebSocket', webConsoleEnabled: true);

    if (!hasWebSocket) {
      throw WebSocketPushNotSupportedException();
    }

    // Access session-level capability directly - getCapabilityProperties doesn't work correctly
    // for session-level capabilities on Stalwart servers
    final wsCapability = session.capabilities[CapabilityIdentifier.jmapWebSocket] as WebSocketCapability?;
    log('WebSocketDatasourceImpl::_verifyWebSocketCapabilities: supportsPush=${wsCapability?.supportsPush}', webConsoleEnabled: true);

    if (wsCapability?.supportsPush != true) {
      throw WebSocketPushNotSupportedException();
    }
  }

  Uri _getWebSocketUri(Session session, AccountId accountId) {
    // Access session-level capability directly - getCapabilityProperties doesn't work correctly
    // for session-level capabilities on Stalwart servers
    final webSocketCapability = session.capabilities[CapabilityIdentifier.jmapWebSocket] as WebSocketCapability?;
    if (webSocketCapability?.supportsPush != true) {
      throw WebSocketPushNotSupportedException();
    }
    log('WebSocketDatasourceImpl::_getWebSocketUri: webSocketCapability = ${webSocketCapability?.toJson()}', webConsoleEnabled: true);
    final webSocketUri = webSocketCapability?.url;
    if (webSocketUri == null) throw WebSocketUriUnavailableException();

    return webSocketUri;
  }

  /// Redacts sensitive query parameters from a URI for safe logging.
  String _redactSensitiveParams(Uri uri) {
    const sensitiveKeys = {'access_token', 'authorization', 'ticket'};
    if (uri.queryParameters.keys.any((k) => sensitiveKeys.contains(k))) {
      final redacted = uri.queryParameters.map((k, v) =>
        MapEntry(k, sensitiveKeys.contains(k) ? '[REDACTED]' : v));
      return uri.replace(queryParameters: redacted).toString();
    }
    return uri.toString();
  }
}

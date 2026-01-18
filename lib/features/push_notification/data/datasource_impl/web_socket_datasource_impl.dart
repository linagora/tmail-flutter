
import 'dart:async';

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
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

      // Check if server supports James-style ticket authentication
      final hasTicketAuth = CapabilityIdentifier.jmapWebSocketTicket.isSupported(session, accountId);
      log('WebSocketDatasourceImpl::getWebSocketChannel: hasTicketAuth=$hasTicketAuth');

      Uri connectionUri;
      if (hasTicketAuth) {
        // Use James ticket-based authentication
        final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
        connectionUri = Uri.parse('${webSocketUri.ensureWebSocketUri().toString()}?ticket=$webSocketTicket');
        log('WebSocketDatasourceImpl::getWebSocketChannel: Using ticket auth');
      } else {
        // Use standard token/basic authentication (for Stalwart and other JMAP servers)
        connectionUri = await _buildAuthUri(webSocketUri);
        log('WebSocketDatasourceImpl::getWebSocketChannel: Using standard auth');
      }

      log('WebSocketDatasourceImpl::getWebSocketChannel: Connecting to $connectionUri');
      final webSocketChannel = WebSocketChannel.connect(
        connectionUri,
        protocols: ["jmap"],
      );

      await webSocketChannel.ready;
      log('WebSocketDatasourceImpl::getWebSocketChannel: WebSocket connected successfully');

      return webSocketChannel;
    }).catchError(_exceptionThrower.throwException);
  }

  Future<Uri> _buildAuthUri(Uri webSocketUri) async {
    final wsUri = webSocketUri.ensureWebSocketUri();

    try {
      final authInterceptors = Get.find<AuthorizationInterceptors>();
      final authType = authInterceptors.authenticationType;
      log('WebSocketDatasourceImpl::_buildAuthUri: authType=$authType');

      if (authType == AuthenticationType.oidc) {
        // For OIDC, pass the access token as query parameter
        final token = authInterceptors.currentToken;
        log('WebSocketDatasourceImpl::_buildAuthUri: OIDC token available=${token != null}');
        if (token != null && token.isNotEmpty) {
          return wsUri.replace(queryParameters: {
            ...wsUri.queryParameters,
            'access_token': token,
          });
        }
      } else if (authType == AuthenticationType.basic) {
        // For basic auth, pass credentials as authorization query parameter
        final basicAuth = authInterceptors.basicAuthCredentials;
        log('WebSocketDatasourceImpl::_buildAuthUri: Basic auth available=${basicAuth != null}');
        if (basicAuth != null && basicAuth.isNotEmpty) {
          return wsUri.replace(queryParameters: {
            ...wsUri.queryParameters,
            'authorization': 'Basic $basicAuth',
          });
        }
      }
      log('WebSocketDatasourceImpl::_buildAuthUri: No auth credentials available, connecting without auth');
    } catch (e) {
      log('WebSocketDatasourceImpl::_buildAuthUri: Error getting auth: $e');
    }

    return wsUri;
  }

  void _verifyWebSocketCapabilities(Session session, AccountId accountId) {
    // Only require jmapWebSocket capability, not ticket (ticket is James-specific)
    if (!CapabilityIdentifier.jmapWebSocket.isSupported(session, accountId)
      || session.getCapabilityProperties<WebSocketCapability>(
        accountId,
        CapabilityIdentifier.jmapWebSocket)?.supportsPush != true
    ) {
      throw WebSocketPushNotSupportedException();
    }
  }

  Uri _getWebSocketUri(Session session, AccountId accountId) {
    final webSocketCapability = session.getCapabilityProperties<WebSocketCapability>(
      accountId,
      CapabilityIdentifier.jmapWebSocket);
    if (webSocketCapability?.supportsPush != true) {
      throw WebSocketPushNotSupportedException();
    }
    log('WebSocketDatasourceImpl::_getWebSocketUri: webSocketCapability = ${webSocketCapability?.toJson()}');
    final webSocketUri = webSocketCapability?.url;
    if (webSocketUri == null) throw WebSocketUriUnavailableException();

    return webSocketUri;
  }
}
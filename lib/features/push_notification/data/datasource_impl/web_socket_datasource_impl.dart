
import 'dart:async';

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
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
      final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
      final webSocketUri = _getWebSocketUri(session, accountId);
      final webSocketChannel = WebSocketChannel.connect(
        Uri.parse('${webSocketUri.ensureWebSocketUri().toString()}?ticket=$webSocketTicket'),
        protocols: ["jmap"],
      );

      await webSocketChannel.ready;

      return webSocketChannel;
    }).catchError(_exceptionThrower.throwException);
  }

  void _verifyWebSocketCapabilities(Session session, AccountId accountId) {
    if (!CapabilityIdentifier.jmapWebSocket.isSupported(session, accountId)
      || !CapabilityIdentifier.jmapWebSocketTicket.isSupported(session, accountId)
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
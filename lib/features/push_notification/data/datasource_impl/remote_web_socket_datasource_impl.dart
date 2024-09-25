import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RemoteWebSocketDatasourceImpl implements WebSocketDatasource {
  final WebSocketApi _webSocketApi;
  final ExceptionThrower _exceptionThrower;
  
  const RemoteWebSocketDatasourceImpl(this._webSocketApi, this._exceptionThrower);

  @override
  Stream getWebSocketChannel(Session session, AccountId accountId) {
    return Stream
      .castFrom(_getWebSocketChannel(session, accountId))
      .doOnError(_exceptionThrower.throwException);
  }

  Stream _getWebSocketChannel(
    Session session,
    AccountId accountId,
    [int retryRemained = 3]
    ) async* {
    try {
      _verifyWebSocketCapabilities(session, accountId);
      final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
      final webSocketUri = _getWebSocketUri(session, accountId);
      
      final webSocketChannel = WebSocketChannel.connect(
        Uri.parse('$webSocketUri?ticket=$webSocketTicket'));
      await webSocketChannel.ready;
      webSocketChannel.sink.add(jsonEncode({"@type": "WebSocketPushEnable"}));
      
      yield* webSocketChannel.stream;
    } catch (e) {
      logError('RemoteWebSocketDatasourceImpl::getWebSocketChannel():error: $e');
      if (retryRemained > 0) {
        yield* _getWebSocketChannel(session, accountId, retryRemained - 1);
      } else {
        rethrow;
      }
    }
  }

  void _verifyWebSocketCapabilities(Session session, AccountId accountId) {
    if (!CapabilityIdentifier.jmapWebSocket.isSupported(session, accountId)
      || !CapabilityIdentifier.jmapWebSocketTicket.isSupported(session, accountId)
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
    final webSocketUri = webSocketCapability?.url;
    if (webSocketUri == null) throw WebSocketUriUnavailableException();

    return webSocketUri;
  }
}
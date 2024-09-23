import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/web_socket_ticket_capability.dart';
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
  
  RemoteWebSocketDatasourceImpl(this._webSocketApi, this._exceptionThrower);

  int _webSocketRetryRemained = 3;

  @override
  Stream getWebSocketChannel(Session session, AccountId accountId) {
    return Stream
      .castFrom(_getWebSocketChannel(session, accountId))
      .doOnError(_exceptionThrower.throwException);
  }

  Stream _getWebSocketChannel(Session session, AccountId accountId) async* {
    try {
      _verifyWebSocketCapabilities(session, accountId);
      final webSocketTicket = await _generateWebSocketTicket(session, accountId);
      final webSocketUri = _getWebSocketUri(session, accountId);
      
      final webSocketChannel = WebSocketChannel.connect(
        Uri.parse('$webSocketUri?ticket=$webSocketTicket'),
        protocols: ['jmap']);
      await webSocketChannel.ready;
      webSocketChannel.sink.add(jsonEncode({"@type": "WebSocketPushEnable"}));
      
      yield* webSocketChannel.stream;
    } catch (e) {
      log('RemoteWebSocketDatasourceImpl::getWebSocketChannel():error: $e');
      if (_webSocketRetryRemained > 0) {
        _webSocketRetryRemained--;
        yield* _getWebSocketChannel(session, accountId);
      } else {
        rethrow;
      }
    }
  }

  void _verifyWebSocketCapabilities(Session session, AccountId accountId) {
    requireCapability(
      session,
      accountId,
      [
        CapabilityIdentifier.jmapWebSocket,
        CapabilityIdentifier.jmapWebSocketTicket
      ]
    );
  }

  Future<String> _generateWebSocketTicket(Session session, AccountId accountId) async {
    final webSocketTicketCapability = session.getCapabilityProperties<WebSocketTicketCapability>(
      accountId,
      CapabilityIdentifier.jmapWebSocketTicket);

    final webSocketTicketGenerationUrl = webSocketTicketCapability?.generationEndpoint;
    if (webSocketTicketGenerationUrl == null) throw WebSocketTicketUnavailableException();
    final webSocketTicket = await _webSocketApi.getWebSocketTicket('$webSocketTicketGenerationUrl');
    if (webSocketTicket.ticket == null) throw WebSocketTicketUnavailableException();

    return webSocketTicket.ticket!;
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

import 'package:core/data/constants/constant.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/broadcast_channel/broadcast_channel.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/websocket_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/connect_web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/web_socket_exceptions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/web_socket_action.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:universal_html/html.dart';

class WebSocketDatasourceImpl implements WebSocketDatasource {
  final WebSocketApi _webSocketApi;
  final ExceptionThrower _exceptionThrower;
  
  const WebSocketDatasourceImpl(this._webSocketApi, this._exceptionThrower);

  static const String _webSocketClosed = 'webSocketClosed';

  @override
  Stream getWebSocketChannel(Session session, AccountId accountId) {
    return Stream
      .castFrom(_getWebSocketChannel(session, accountId))
      .doOnError(_exceptionThrower.throwException);
  }

  Stream _getWebSocketChannel(
    Session session,
    AccountId accountId,
  ) async* {
    final broadcastChannel = BroadcastChannel(Constant.wsServiceWorkerBroadcastChannel);
    try {
      _verifyWebSocketCapabilities(session, accountId);
      final webSocketTicket = await _webSocketApi.getWebSocketTicket(session, accountId);
      final webSocketUri = _getWebSocketUri(session, accountId);
      window.navigator.serviceWorker?.controller?.postMessage(ConnectWebSocketMessage(
        webSocketAction: WebSocketAction.connect,
        webSocketUrl: webSocketUri.toString(),
        webSocketTicket: webSocketTicket
      ).toJson());
      
      yield* _webSocketListener(broadcastChannel);
    } catch (e) {
      logError('RemoteWebSocketDatasourceImpl::getWebSocketChannel():error: $e');
      rethrow;
    }
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
    final webSocketUri = webSocketCapability?.url;
    if (webSocketUri == null) throw WebSocketUriUnavailableException();

    return webSocketUri;
  }

  Stream _webSocketListener(BroadcastChannel broadcastChannel) {
    return broadcastChannel.onMessage.map((event) {
      if (event.data == _webSocketClosed) {
        throw WebSocketClosedException();
      }

      return event.data;
    });
  }
}
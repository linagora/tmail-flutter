import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketRepository {
  Future<WebSocketChannel> getWebSocketChannel(
    Session session,
    AccountId accountId);
}
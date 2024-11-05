import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/web_socket_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/web_socket_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketRepositoryImpl implements WebSocketRepository {
  final WebSocketDatasource _webSocketDatasource;

  WebSocketRepositoryImpl(this._webSocketDatasource);

  @override
  Future<WebSocketChannel> getWebSocketChannel(
    Session session,
    AccountId accountId
  ) => _webSocketDatasource.getWebSocketChannel(session, accountId);
}
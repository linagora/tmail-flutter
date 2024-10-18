import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

abstract class WebSocketDatasource {
  Stream<dynamic> getWebSocketChannel(Session session, AccountId accountId);
}
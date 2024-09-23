import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

abstract class WebSocketRepository {
  Stream getWebSocketChannel(Session session, AccountId accountId);
}
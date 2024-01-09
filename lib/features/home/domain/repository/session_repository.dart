import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';

abstract class SessionRepository {
  Future<Session> getSession();

  Future<void> storeSession(Session session, AccountId accountId, UserName userName);

  Future<Session> getStoredSession(AccountId accountId, UserName userName);
}
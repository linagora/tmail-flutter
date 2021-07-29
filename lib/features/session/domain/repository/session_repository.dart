import 'package:jmap_dart_client/jmap/core/session/session.dart';

abstract class SessionRepository {
  Future<Session> getSession();
}
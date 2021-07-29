import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/domain/repository/session_repository.dart';

class SessionRepositoryImpl extends SessionRepository {

  final SessionDataSource sessionDataSource;

  SessionRepositoryImpl(this.sessionDataSource);

  @override
  Future<Session> getSession() {
    return sessionDataSource.getSession();
  }
}
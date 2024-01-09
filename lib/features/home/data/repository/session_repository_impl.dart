import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/home/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/home/domain/repository/session_repository.dart';

class SessionRepositoryImpl extends SessionRepository {

  final Map<DataSourceType, SessionDataSource> sessionDataSource;

  SessionRepositoryImpl(this.sessionDataSource);

  @override
  Future<Session> getSession() {
    return sessionDataSource[DataSourceType.network]!.getSession();
  }

  @override
  Future<void> storeSession(Session session, AccountId accountId, UserName userName) {
    return sessionDataSource[DataSourceType.hiveCache]!.storeSession(session, accountId, userName);
  }

  @override
  Future<Session> getStoredSession(AccountId accountId, UserName userName) {
    return sessionDataSource[DataSourceType.hiveCache]!.getStoredSession(accountId, userName);
  }
}
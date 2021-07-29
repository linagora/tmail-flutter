import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';

class SessionDataSourceImpl extends SessionDataSource {

  final SessionAPI sessionAPI;

  SessionDataSourceImpl(this.sessionAPI);

  @override
  Future<Session> getSession() {
    return Future.sync(() async {
      return await sessionAPI.getSession();
    }).catchError((error) {
      throw error;
    });
  }
}
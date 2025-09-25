import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';

abstract class ServerSettingsDataSource {
  Future<TMailServerSettings> getServerSettings(AccountId accountId);
  Future<TMailServerSettings> updateServerSettings(
    Session session,
    AccountId accountId, 
    TMailServerSettings serverSettings);
}
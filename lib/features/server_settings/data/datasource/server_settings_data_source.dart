import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';

abstract class ServerSettingsDataSource {
  Future<TMailServerSettings> getServerSettings(AccountId accountId);
  Future<TMailServerSettings> updateServerSettings(
    AccountId accountId, 
    TMailServerSettings serverSettings);
}
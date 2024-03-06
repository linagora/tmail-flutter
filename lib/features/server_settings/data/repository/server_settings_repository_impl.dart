import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';

class ServerSettingsRepositoryImpl implements ServerSettingsRepository {
  ServerSettingsRepositoryImpl(this._serverSettingsDataSource);

  final ServerSettingsDataSource _serverSettingsDataSource;

  @override
  Future<TMailServerSettings> getServerSettings(AccountId accountId) =>
    _serverSettingsDataSource.getServerSettings(accountId);

  @override
  Future<TMailServerSettings> updateServerSettings(
    AccountId accountId,
    TMailServerSettings serverSettings)
      => _serverSettingsDataSource.updateServerSettings(accountId, serverSettings);
}
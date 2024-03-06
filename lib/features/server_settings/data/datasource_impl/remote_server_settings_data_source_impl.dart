import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class RemoteServerSettingsDataSourceImpl implements ServerSettingsDataSource {
  final ServerSettingsAPI _serverSettingsAPI;
  final ExceptionThrower _exceptionThrower;

  RemoteServerSettingsDataSourceImpl(
    this._serverSettingsAPI, 
    this._exceptionThrower);

  @override
  Future<TMailServerSettings> getServerSettings(AccountId accountId) {
    return Future.sync(() async {
      return await _serverSettingsAPI.getServerSettings(accountId);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<TMailServerSettings> updateServerSettings(AccountId accountId, TMailServerSettings serverSettings) {
    return Future.sync(() async {
      return await _serverSettingsAPI.updateServerSettings(accountId, serverSettings);
    }).catchError(_exceptionThrower.throwException);
  }
}
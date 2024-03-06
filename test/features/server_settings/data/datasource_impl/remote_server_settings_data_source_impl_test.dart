import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/server_settings_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource_impl/remote_server_settings_data_source_impl.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

import 'remote_server_settings_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServerSettingsAPI>()])
void main() {
  final serverSettings = TMailServerSettings(
    id: ServerSettingsId(id: Id('123')),
    settings: TMailServerSettingOptions(alwaysReadReceipts: true),
  );
  final accountId = AccountId(Id('321'));
  final serverSettingsAPI = MockServerSettingsAPI();
  final remoteServerSettingsDataSource = RemoteServerSettingsDataSourceImpl(
    serverSettingsAPI,
    RemoteExceptionThrower(),
  );

  group('remote server settings data source', () {
    group('get server settings', () {
      test('should return value when ServerSettingsAPI returns value',() async {
        // arrange
        when(serverSettingsAPI.getServerSettings(any))
          .thenAnswer((_) async => serverSettings);

        // act
        final result = await remoteServerSettingsDataSource
          .getServerSettings(accountId);

        // assert
        expect(result, serverSettings);
      });

      test('should rethrow exception when ServerSettingsAPI throws exception',() async {
        // arrange
        when(serverSettingsAPI.getServerSettings(any))
          .thenThrow(NotFoundServerSettingsException());

        // assert
        expect(
          () => remoteServerSettingsDataSource.getServerSettings(accountId),
          throwsA(const TypeMatcher<NotFoundServerSettingsException>()));
      });
    });

    group('update server settings', () {
      test('should return value when ServerSettingsAPI returns value',() async {
        // arrange
        when(serverSettingsAPI.updateServerSettings(any, any))
          .thenAnswer((_) async => serverSettings);

        // act
        final result = await remoteServerSettingsDataSource
          .updateServerSettings(accountId, serverSettings);

        // assert
        expect(result, serverSettings);
      });

      test('should rethrow exception when ServerSettingsAPI throws exception',() async {
        // arrange
        when(serverSettingsAPI.updateServerSettings(any, any))
          .thenThrow(CanNotUpdateServerSettingsException());

        // assert
        expect(
          () => remoteServerSettingsDataSource.updateServerSettings(
            accountId, 
            serverSettings),
          throwsA(const TypeMatcher<CanNotUpdateServerSettingsException>()));
      });
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/data/datasource/server_settings_data_source.dart';
import 'package:tmail_ui_user/features/server_settings/data/repository/server_settings_repository_impl.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';

import 'server_settings_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServerSettingsDataSource>()])
void main() {
  final serverSettings = TMailServerSettings();
  final accountId = AccountId(Id('123'));
  final serverSettingsDataSource = MockServerSettingsDataSource();
  final serverSettingsRepository = ServerSettingsRepositoryImpl(
    serverSettingsDataSource,
  );

  group('server settings repository', () {
    group('get server settings', () {
      test('should return value when ServerSettingsDataSource returns value', () async {
        // arrange
        when(serverSettingsDataSource.getServerSettings(accountId))
          .thenAnswer((_) async => serverSettings);
          
        // act
        final result = await serverSettingsRepository.getServerSettings(accountId);

        // assert
        expect(result, serverSettings);
      });

      test('should rethrow exception when ServerSettingsDataSource throws exception', () async {
        // arrange
        when(serverSettingsDataSource.getServerSettings(accountId))
          .thenThrow(NotFoundServerSettingsException());

        // assert
        expect(
          () => serverSettingsRepository.getServerSettings(accountId),
          throwsA(const TypeMatcher<NotFoundServerSettingsException>()));
      });
    });

    group('update server settings', () {
      test('should return value when ServerSettingsDataSource returns value', () async {
        // arrange
        when(serverSettingsDataSource.updateServerSettings(accountId, serverSettings))
          .thenAnswer((_) async => serverSettings);

        // act
        final result = await serverSettingsRepository
          .updateServerSettings(accountId, serverSettings);

        // assert
        expect(result, serverSettings);
      });

      test('should rethrow exception when ServerSettingsDataSource throws exception', () async {
        // arrange
        when(serverSettingsDataSource.updateServerSettings(accountId, serverSettings))
          .thenThrow(NotFoundServerSettingsException());

        // assert
        expect(
          () => serverSettingsRepository.updateServerSettings(accountId, serverSettings),
          throwsA(const TypeMatcher<NotFoundServerSettingsException>()));
      });
    });
  });
}
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';

import 'get_server_setting_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServerSettingsRepository>()])
void main() {
  final accountId = AccountId(Id('123'));
  final serverSettingsRepository = MockServerSettingsRepository();
  final getServerSettingInteractor = 
    GetServerSettingInteractor(serverSettingsRepository);

  group('get always read receipt setting interactor', () {
    test('should return right with value returned from repository', () {
      // arrange
      when(serverSettingsRepository.getServerSettings(any))
        .thenAnswer((_) async => TMailServerSettings(
          settings: TMailServerSettingOptions(
            alwaysReadReceipts: false)));
      
      // assert
      expect(
        getServerSettingInteractor.execute(accountId),
        emitsInOrder([
          Right(GettingServerSetting()),
          Right(GetServerSettingSuccess(TMailServerSettingOptions(alwaysReadReceipts: false))),
        ])
      );
    });

    test('should return left with exception returned from repository', () {
      // arrange  
      final exception = NotFoundServerSettingsException();
      when(serverSettingsRepository.getServerSettings(any)).thenThrow(exception);
      
      // assert
      expect(
        getServerSettingInteractor.execute(accountId),
        emitsInOrder([
          Right(GettingServerSetting()),
          Left(GetServerSettingFailure(exception)),
        ])
      );
    });
  });
}
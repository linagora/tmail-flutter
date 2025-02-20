import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_server_setting_interactor.dart';

import 'update_server_setting_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServerSettingsRepository>()])
void main() {
  final accountId = AccountId(Id('123'));
  const alwaysReadReceipts = false;
  final serverSettings = TMailServerSettings(
    settings: TMailServerSettingOptions(alwaysReadReceipts: alwaysReadReceipts)
  );
  final serverSettingsRepository = MockServerSettingsRepository();
  final updateServerSettingInteractor = UpdateServerSettingInteractor(serverSettingsRepository);
  group('update always read receipt setting interactor', () {
    test('should return right with value returned from repository', () {
      // arrange
      when(serverSettingsRepository.updateServerSettings(any, any))
        .thenAnswer((_) async => serverSettings);
      
      // assert
      expect(
        updateServerSettingInteractor.execute(
          accountId,
          TMailServerSettingOptions(alwaysReadReceipts: alwaysReadReceipts),
        ),
        emitsInOrder([
          Right(UpdatingServerSetting()),
          Right(UpdateServerSettingSuccess(TMailServerSettingOptions(alwaysReadReceipts: alwaysReadReceipts))),
        ])
      );
    });

    test('should return left with exception returned from repository', () {
      // arrange
      final exception = NotFoundServerSettingsException();
      when(serverSettingsRepository.updateServerSettings(any, any))
        .thenThrow(exception);
      
      // assert
      expect(
        updateServerSettingInteractor.execute(
          accountId,
          TMailServerSettingOptions(alwaysReadReceipts: alwaysReadReceipts),
        ),
        emitsInOrder([
          Right(UpdatingServerSetting()),
          Left(UpdateServerSettingFailure(exception)),
        ])
      );
    });
  });
}
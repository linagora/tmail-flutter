import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_always_read_receipt_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';

import 'get_always_read_receipt_setting_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ServerSettingsRepository>()])
void main() {
  final accountId = AccountId(Id('123'));
  final serverSettingsRepository = MockServerSettingsRepository();
  final getAlwaysReadReceiptSettingInteractor = 
    GetAlwaysReadReceiptSettingInteractor(serverSettingsRepository);

  group('get always read receipt setting interactor', () {
    test('should return right with value returned from repository', () {
      // arrange
      when(serverSettingsRepository.getServerSettings(any))
        .thenAnswer((_) async => TMailServerSettings(
          settings: TMailServerSettingOptions(
            alwaysReadReceipts: false)));
      
      // assert
      expect(
        getAlwaysReadReceiptSettingInteractor.execute(accountId),
        emitsInOrder([
          Right(GettingAlwaysReadReceiptSetting()),
          Right(GetAlwaysReadReceiptSettingSuccess(alwaysReadReceiptEnabled: false)),
        ])
      );
    });

    test('should return left with exception returned from repository', () {
      // arrange  
      final exception = NotFoundServerSettingsException();
      when(serverSettingsRepository.getServerSettings(any)).thenThrow(exception);
      
      // assert
      expect(
        getAlwaysReadReceiptSettingInteractor.execute(accountId),
        emitsInOrder([
          Right(GettingAlwaysReadReceiptSetting()),
          Left(GetAlwaysReadReceiptSettingFailure(exception)),
        ])
      );
    });
  });
}
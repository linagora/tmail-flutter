import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_always_read_receipt_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/update_always_read_receipt_setting_interactor.dart';

import 'get_always_read_receipt_setting_interactor_test.mocks.dart';

void main() {
  final accountId = AccountId(Id('123'));
  const alwaysReadReceipts = false;
  final serverSettings = TMailServerSettings(
    settings: TMailServerSettingOptions(alwaysReadReceipts: alwaysReadReceipts)
  );
  final serverSettingsRepository = MockServerSettingsRepository();
  final updateAlwaysReadReceiptSettingInteractor = 
    UpdateAlwaysReadReceiptSettingInteractor(serverSettingsRepository);
  group('update always read receipt setting interactor', () {
    test('should return right with value returned from repository', () {
      // arrange
      when(serverSettingsRepository.updateServerSettings(any, any))
        .thenAnswer((_) async => serverSettings);
      
      // assert
      expect(
        updateAlwaysReadReceiptSettingInteractor
          .execute(accountId, alwaysReadReceipts),
        emitsInOrder([
          Right(UpdatingAlwaysReadReceiptSetting()),
          Right(UpdateAlwaysReadReceiptSettingSuccess(isEnabled: alwaysReadReceipts)),
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
        updateAlwaysReadReceiptSettingInteractor.execute(accountId, alwaysReadReceipts),
        emitsInOrder([
          Right(UpdatingAlwaysReadReceiptSetting()),
          Left(UpdateAlwaysReadReceiptSettingFailure(exception)),
        ])
      );
    });
  });
}
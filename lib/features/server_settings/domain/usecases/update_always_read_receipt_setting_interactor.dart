import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_always_read_receipt_setting_state.dart';

class UpdateAlwaysReadReceiptSettingInteractor {
  final ServerSettingsRepository _serverSettingsRepository;

  UpdateAlwaysReadReceiptSettingInteractor(this._serverSettingsRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId, 
    bool isEnabled
  ) async* {
    yield Right(UpdatingAlwaysReadReceiptSetting());
    try {
      final result = await _serverSettingsRepository.updateServerSettings(
        accountId, 
        TMailServerSettings(
          settings: TMailServerSettingOptions(alwaysReadReceipts: isEnabled)
        )
      );
      yield Right(UpdateAlwaysReadReceiptSettingSuccess(
        isEnabled: result.settings?.alwaysReadReceipts ?? true));
    } catch (e) {
      yield Left(UpdateAlwaysReadReceiptSettingFailure(e));
    }
  }
}
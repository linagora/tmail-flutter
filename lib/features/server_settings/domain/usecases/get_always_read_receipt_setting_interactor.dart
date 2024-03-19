import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_always_read_receipt_setting_state.dart';

class GetAlwaysReadReceiptSettingInteractor {
  final ServerSettingsRepository _serverSettingsRepository;

  GetAlwaysReadReceiptSettingInteractor(this._serverSettingsRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right(GettingAlwaysReadReceiptSetting());
      final result = await _serverSettingsRepository.getServerSettings(accountId);
      yield Right(GetAlwaysReadReceiptSettingSuccess(
        alwaysReadReceiptEnabled: result.settings?.alwaysReadReceipts ?? false));
    } catch (e) {
      yield Left(GetAlwaysReadReceiptSettingFailure(e));
    }
  }
}
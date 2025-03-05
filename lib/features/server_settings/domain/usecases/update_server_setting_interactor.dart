import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';

class UpdateServerSettingInteractor {
  final ServerSettingsRepository _serverSettingsRepository;

  UpdateServerSettingInteractor(this._serverSettingsRepository);

  Stream<Either<Failure, Success>> execute(
    AccountId accountId,
    TMailServerSettingOptions newSettingOption,
  ) async* {
    yield Right(UpdatingServerSetting());
    try {
      final serverSetting = await _serverSettingsRepository.updateServerSettings(
        accountId, 
        TMailServerSettings(settings: newSettingOption),
      );
      final settingOption = serverSetting.settings;
      if (settingOption == null) {
        yield Left(UpdateServerSettingFailure(NotFoundServerSettingsException()));
      } else {
        yield Right(UpdateServerSettingSuccess(settingOption));
      }
    } catch (e) {
      yield Left(UpdateServerSettingFailure(e));
    }
  }
}
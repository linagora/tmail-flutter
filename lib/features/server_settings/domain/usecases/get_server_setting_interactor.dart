import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';

class GetServerSettingInteractor {
  final ServerSettingsRepository _serverSettingsRepository;

  GetServerSettingInteractor(this._serverSettingsRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId) async* {
    try {
      yield Right(GettingServerSetting());
      final serverSetting = await _serverSettingsRepository.getServerSettings(accountId);
      final settingOption = serverSetting.settings;
      if (settingOption == null) {
        yield Left(GetServerSettingFailure(NotFoundSettingOptionException()));
      } else {
        yield Right(GetServerSettingSuccess(settingOption));
      }
    } catch (e) {
      yield Left(GetServerSettingFailure(e));
    }
  }
}
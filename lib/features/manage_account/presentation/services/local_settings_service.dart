import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';

class LocalSettingsService extends GetxService {
  final GetLocalSettingsInteractor _getLocalSettingsInteractor;

  LocalSettingsService(this._getLocalSettingsInteractor);

  final localSettings = PreferencesSetting.initial().obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalSettings();
  }

  void refresh() => _loadLocalSettings();

  void _loadLocalSettings() {
    _getLocalSettingsInteractor.execute().last.then(
      (result) => result.fold(
        (failure) => logWarning(
          'LocalSettingsService::_loadLocalSettings:failure: $failure',
        ),
        (success) {
          if (success is GetLocalSettingsSuccess) {
            localSettings.value = success.preferencesSetting;
          }
        },
      ),
    );
  }
}

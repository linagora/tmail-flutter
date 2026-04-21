import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';

class LocalSettingsService extends GetxService {
  final GetLocalSettingsInteractor _getLocalSettingsInteractor;

  LocalSettingsService(this._getLocalSettingsInteractor);

  final localSettings = PreferencesSetting.initial().obs;

  Future<void>? _pendingLoad;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() => _pendingLoad ??= _loadLocalSettings()
      .whenComplete(() => _pendingLoad = null);

  Future<void> _loadLocalSettings() {
    return _getLocalSettingsInteractor.execute().last.then(
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
    ).catchError((error, stackTrace) {
      logWarning(
        'LocalSettingsService::_loadLocalSettings:error: $error | stackTrace: $stackTrace',
      );
    });
  }
}

import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';

class LocalSettingsService extends GetxService {
  final GetLocalSettingsInteractor _getLocalSettingsInteractor;
  final Rxn<ThreadDetailUIAction> _threadDetailUIAction;

  LocalSettingsService(
    this._getLocalSettingsInteractor,
    this._threadDetailUIAction,
  );

  final localSettings = PreferencesSetting.initial().obs;

  Worker? _settingsWorker;

  @override
  void onInit() {
    super.onInit();
    _listenToSettingsChanges();
    _loadLocalSettings();
  }

  @override
  void onClose() {
    _settingsWorker?.dispose();
    super.onClose();
  }

  void _listenToSettingsChanges() {
    _settingsWorker = ever(
      _threadDetailUIAction,
      (action) {
        if (action is UpdatedThreadDetailSettingAction) {
          _loadLocalSettings();
        }
      },
    );
  }

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

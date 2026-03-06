import 'package:core/core.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/emit_state_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_local_settings_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnPreferencesSettingChanged = void Function({bool isThreadStateChanged});

mixin SetupPreferencesSettingMixin on EmitStateMixin {
  PreferencesSetting? _preferencesSetting;

  PreferencesSetting? get preferencesSetting => _preferencesSetting;

  BaseController get controller;

  OnPreferencesSettingChanged get onPreferencesSettingChanged;

  bool? get isThreadDetailEnabled =>
      _preferencesSetting?.isThreadDetailEnabled == true;

  void setPreferencesSetting(PreferencesSetting setting) =>
      _preferencesSetting = setting;

  void clearPreferencesSetting() {
    _preferencesSetting = null;
  }

  void loadPreferencesSetting() {
    final settingsInteractor = getBinding<GetLocalSettingsInteractor>();
    if (settingsInteractor == null) {
      logWarning('SetupPreferencesSettingMixin::loadPreferencesSetting: GetLocalSettingsInteractor is NULL');
      return;
    }

    controller.consumeState(settingsInteractor.execute());
  }

  void scribeLoadPreferencesSettingSuccess(GetLocalSettingsSuccess success) {
    final currentPreferencesSetting = _preferencesSetting;
    final newPreferencesSetting = success.preferencesSetting;

    if (currentPreferencesSetting != null) {
      _verifyThreadSettingStateChanged(
        currentSetting: currentPreferencesSetting,
        newSetting: newPreferencesSetting,
      );
    }

    setPreferencesSetting(newPreferencesSetting);
  }

  void scribeLoadPreferencesSettingFailure(GetLocalSettingsFailure failure) {
    clearPreferencesSetting();
  }

  void _verifyThreadSettingStateChanged({
    required PreferencesSetting currentSetting,
    required PreferencesSetting newSetting,
  }) {
    final isChanged = currentSetting.isThreadDetailEnabled !=
        newSetting.isThreadDetailEnabled;
    log('SetupPreferencesSettingMixin::_verifyThreadSettingStateChanged: isChanged = $isChanged');
    if (isChanged) {
      onPreferencesSettingChanged(isThreadStateChanged: isChanged);
    }
  }
}

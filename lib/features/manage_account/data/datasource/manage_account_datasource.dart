import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

abstract class ManageAccountDataSource {
  Future<void> persistLanguage(Locale localeCurrent);

  Future<PreferencesSetting> toggleLocalSettingsState(PreferencesConfig preferencesConfig);

  Future<PreferencesSetting> getLocalSettings();
}

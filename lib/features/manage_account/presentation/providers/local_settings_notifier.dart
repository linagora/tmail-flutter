import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

class LocalSettingsNotifier extends Notifier<PreferencesSetting> {
  @override
  PreferencesSetting build() {
    return PreferencesSetting.initial();
  }

  void update(PreferencesSetting settings) {
    state = settings;
  }
}

final localSettingsNotifierProvider =
    NotifierProvider<LocalSettingsNotifier, PreferencesSetting>(
  () => LocalSettingsNotifier(),
);

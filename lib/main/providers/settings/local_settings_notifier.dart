import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

part 'local_settings_notifier.g.dart';

@Riverpod(keepAlive: true)
class LocalSettingsNotifier extends _$LocalSettingsNotifier {
  @override
  PreferencesSetting build() => PreferencesSetting.initial();

  /// Sets the state before the loaded flag, so a reader woken by the flag sees the saved settings.
  void update(PreferencesSetting settings) {
    state = settings;
    markLoaded();
  }

  void markLoaded() => ref.read(localSettingsLoadedProvider.notifier).markLoaded();
}

/// False until the saved settings are read (or their read fails), so a reader can tell the defaults from saved values.
@Riverpod(keepAlive: true)
class LocalSettingsLoaded extends _$LocalSettingsLoaded {
  @override
  bool build() => false;

  void markLoaded() => state = true;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

part 'local_settings_notifier.g.dart';

@Riverpod(keepAlive: true)
class LocalSettingsNotifier extends _$LocalSettingsNotifier {
  @override
  PreferencesSetting build() => PreferencesSetting.initial();

  void update(PreferencesSetting settings) => state = settings;
}

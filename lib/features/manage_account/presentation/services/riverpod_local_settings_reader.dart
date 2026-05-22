import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/local_settings_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/services/local_settings_reader.dart';

class RiverpodLocalSettingsReader implements ILocalSettingsReader {
  final ProviderContainer _container;

  const RiverpodLocalSettingsReader(this._container);

  @override
  PreferencesSetting get currentSettings =>
      _container.read(localSettingsNotifierProvider);

  @override
  bool get isCollapseThreadsEnabled => currentSettings.isCollapseThreadsEnabled;

  @override
  void Function() listen(void Function(PreferencesSetting) onChange) {
    final sub = _container.listen(
      localSettingsNotifierProvider,
      (_, next) => onChange(next),
      fireImmediately: false,
    );
    return sub.close;
  }
}

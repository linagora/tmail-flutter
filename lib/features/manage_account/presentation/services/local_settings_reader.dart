import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

abstract interface class ILocalSettingsReader {
  bool get isCollapseThreadsEnabled;

  PreferencesSetting get currentSettings;

  /// Registers [onChange] to be called whenever [PreferencesSetting] changes.
  /// Returns a cancel callback; the caller must invoke it in [onClose].
  void Function() listen(void Function(PreferencesSetting) onChange);
}

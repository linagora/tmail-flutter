import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

abstract class ManageAccountRepository {
  Future<void> persistLanguage(Locale localeCurrent);

  Future<void> updateLocalSettings(
    Map<SupportedLocalSetting, LocalSettingOptions?> localSettings,
  );

  Future<Map<SupportedLocalSetting, LocalSettingOptions?>> getLocalSettings(
    List<SupportedLocalSetting> supportedLocalSettings,
  );
}
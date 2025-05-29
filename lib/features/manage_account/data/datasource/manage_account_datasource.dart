import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

abstract class ManageAccountDataSource {
  Future<void> persistLanguage(Locale localeCurrent);

  Future<void> updateLocalSettings(LocalSettingOptions localSettingOptions);

  Future<LocalSettingOptions> getLocalSettings();
}
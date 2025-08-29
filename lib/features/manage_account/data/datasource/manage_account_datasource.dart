import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/preferences_root.dart';

abstract class ManageAccountDataSource {
  Future<void> persistLanguage(Locale localeCurrent);

  Future<void> updateLocalSettings(PreferencesRoot preferencesRoot);

  Future<PreferencesRoot> getLocalSettings();
}
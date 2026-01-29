import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/open_email_in_new_window_config.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late PreferencesSettingManager preferencesSettingManager;

  const preferencesSettingOpenEmailInNewWindowKey =
      'PREFERENCES_SETTING_OPEN_EMAIL_IN_NEW_WINDOW';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    preferencesSettingManager = PreferencesSettingManager(sharedPreferences);
  });

  group('OpenEmailInNewWindow preferences tests', () {
    test(
        'getOpenEmailInNewWindowConfig should return initial config when no stored value',
        () async {
      // act
      final config =
          await preferencesSettingManager.getOpenEmailInNewWindowConfig();

      // assert
      expect(config.isEnabled, false);
    });

    test(
        'getOpenEmailInNewWindowConfig should return stored config when value exists',
        () async {
      // arrange
      final storedConfig = OpenEmailInNewWindowConfig(isEnabled: true);
      await sharedPreferences.setString(
        preferencesSettingOpenEmailInNewWindowKey,
        jsonEncode(storedConfig.toJson()),
      );

      // act
      final config =
          await preferencesSettingManager.getOpenEmailInNewWindowConfig();

      // assert
      expect(config.isEnabled, true);
    });

    test('updateOpenEmailInNewWindow should save enabled state', () async {
      // act
      await preferencesSettingManager.updateOpenEmailInNewWindow(true);

      // assert
      final storedJson = sharedPreferences.getString(
        preferencesSettingOpenEmailInNewWindowKey,
      );
      expect(storedJson, isNotNull);
      final decoded = jsonDecode(storedJson!);
      expect(decoded['isEnabled'], true);
    });

    test('updateOpenEmailInNewWindow should save disabled state', () async {
      // arrange - first enable it
      await preferencesSettingManager.updateOpenEmailInNewWindow(true);

      // act - then disable it
      await preferencesSettingManager.updateOpenEmailInNewWindow(false);

      // assert
      final storedJson = sharedPreferences.getString(
        preferencesSettingOpenEmailInNewWindowKey,
      );
      expect(storedJson, isNotNull);
      final decoded = jsonDecode(storedJson!);
      expect(decoded['isEnabled'], false);
    });

    test('round trip: save and retrieve should return same value', () async {
      // act
      await preferencesSettingManager.updateOpenEmailInNewWindow(true);
      final config =
          await preferencesSettingManager.getOpenEmailInNewWindowConfig();

      // assert
      expect(config.isEnabled, true);
    });

    test('loadPreferences should include OpenEmailInNewWindowConfig',
        () async {
      // arrange
      final storedConfig = OpenEmailInNewWindowConfig(isEnabled: true);
      await sharedPreferences.setString(
        preferencesSettingOpenEmailInNewWindowKey,
        jsonEncode(storedConfig.toJson()),
      );

      // act
      final preferencesSetting =
          await preferencesSettingManager.loadPreferences();

      // assert
      expect(preferencesSetting.openEmailInNewWindowConfig.isEnabled, true);
    });

    test(
        'loadPreferences should return initial OpenEmailInNewWindowConfig when not stored',
        () async {
      // act
      final preferencesSetting =
          await preferencesSettingManager.loadPreferences();

      // assert
      expect(preferencesSetting.openEmailInNewWindowConfig.isEnabled, false);
    });
  });
}

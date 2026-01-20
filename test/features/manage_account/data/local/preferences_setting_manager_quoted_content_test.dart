import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/quoted_content_config.dart';

void main() {
  late SharedPreferences sharedPreferences;
  late PreferencesSettingManager preferencesSettingManager;

  const quotedContentKey = 'PREFERENCES_SETTING_QUOTED_CONTENT';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    preferencesSettingManager = PreferencesSettingManager(sharedPreferences);
  });

  group('PreferencesSettingManager - QuotedContentConfig test', () {
    test('getQuotedContentConfig should return initial config when no saved value', () async {
      // act
      final config = await preferencesSettingManager.getQuotedContentConfig();

      // assert
      expect(config.isHiddenByDefault, true);
    });

    test('getQuotedContentConfig should return saved config when value exists', () async {
      // arrange
      final savedConfig = QuotedContentConfig(isHiddenByDefault: false);
      await sharedPreferences.setString(
        quotedContentKey,
        jsonEncode(savedConfig.toJson()),
      );

      // act
      final config = await preferencesSettingManager.getQuotedContentConfig();

      // assert
      expect(config.isHiddenByDefault, false);
    });

    test('updateQuotedContent should save the config correctly when setting to false', () async {
      // act
      await preferencesSettingManager.updateQuotedContent(false);

      // assert
      final savedJson = sharedPreferences.getString(quotedContentKey);
      expect(savedJson, isNotNull);
      final savedConfig = QuotedContentConfig.fromJson(jsonDecode(savedJson!));
      expect(savedConfig.isHiddenByDefault, false);
    });

    test('updateQuotedContent should save the config correctly when setting to true', () async {
      // arrange - first set to false
      await preferencesSettingManager.updateQuotedContent(false);

      // act - then set back to true
      await preferencesSettingManager.updateQuotedContent(true);

      // assert
      final savedJson = sharedPreferences.getString(quotedContentKey);
      expect(savedJson, isNotNull);
      final savedConfig = QuotedContentConfig.fromJson(jsonDecode(savedJson!));
      expect(savedConfig.isHiddenByDefault, true);
    });

    test('getQuotedContentConfig should return updated config after updateQuotedContent', () async {
      // arrange
      await preferencesSettingManager.updateQuotedContent(false);

      // act
      final config = await preferencesSettingManager.getQuotedContentConfig();

      // assert
      expect(config.isHiddenByDefault, false);
    });

    test('savePreferences should save QuotedContentConfig correctly', () async {
      // arrange
      final config = QuotedContentConfig(isHiddenByDefault: false);

      // act
      await preferencesSettingManager.savePreferences(config);

      // assert
      final savedJson = sharedPreferences.getString(quotedContentKey);
      expect(savedJson, isNotNull);
      final savedConfig = QuotedContentConfig.fromJson(jsonDecode(savedJson!));
      expect(savedConfig.isHiddenByDefault, false);
    });

    test('loadPreferences should include QuotedContentConfig when saved', () async {
      // arrange
      final config = QuotedContentConfig(isHiddenByDefault: false);
      await sharedPreferences.setString(
        quotedContentKey,
        jsonEncode(config.toJson()),
      );

      // act
      final preferencesSetting = await preferencesSettingManager.loadPreferences();

      // assert
      expect(preferencesSetting.quotedContentConfig.isHiddenByDefault, false);
    });
  });
}

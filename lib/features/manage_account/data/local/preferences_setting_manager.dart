import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/default_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/empty_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

class PreferencesSettingManager {
  static const String _preferencesSettingKey = 'PREFERENCES_SETTING';
  static const String _preferencesSettingThreadKey =
      '${_preferencesSettingKey}_THREAD';
  static const String _preferencesSettingSpamReportKey =
      '${_preferencesSettingKey}_SPAM_REPORT';
  static const String _preferencesSettingTextFormattingMenuKey =
      '${_preferencesSettingKey}_TEXT_FORMATTING_MENU';

  const PreferencesSettingManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<PreferencesSetting> loadPreferences() async {
    await _sharedPreferences.reload();

    final keys = _sharedPreferences.getKeys();
    final preferencesKeys =
        keys.where((key) => key.startsWith(_preferencesSettingKey)).toList();

    final listConfigs = preferencesKeys.map((key) {
      final jsonString = _sharedPreferences.getString(key);
      if (jsonString != null) {
        final jsonDecoded = jsonDecode(jsonString);

        switch (key) {
          case _preferencesSettingThreadKey:
            return ThreadDetailConfig.fromJson(jsonDecoded);
          case _preferencesSettingSpamReportKey:
            return SpamReportConfig.fromJson(jsonDecoded);
          case _preferencesSettingTextFormattingMenuKey:
            return TextFormattingMenuConfig.fromJson(jsonDecoded);
          default:
            return DefaultPreferencesConfig.fromJson(jsonDecoded);
        }
      }
      return EmptyPreferencesConfig();
    }).toList();

    if (listConfigs.isEmpty) {
      return PreferencesSetting.initial();
    }

    return PreferencesSetting(listConfigs);
  }

  Future<void> savePreferences(PreferencesConfig config) async {
    if (config is ThreadDetailConfig) {
      await _sharedPreferences.setString(
        _preferencesSettingThreadKey,
        jsonEncode(config.toJson()),
      );
    } else if (config is SpamReportConfig) {
      await _sharedPreferences.setString(
        _preferencesSettingSpamReportKey,
        jsonEncode(config.toJson()),
      );
    } else if (config is TextFormattingMenuConfig) {
      await _sharedPreferences.setString(
        _preferencesSettingTextFormattingMenuKey,
        jsonEncode(config.toJson()),
      );
    } else {
      await _sharedPreferences.setString(
        _preferencesSettingKey,
        jsonEncode(config.toJson()),
      );
    }
  }

  Future<void> updateThread(bool isEnabled) async {
    final currentConfig = await getThreadConfig();
    final updatedConfig = currentConfig.copyWith(isEnabled: isEnabled);
    await savePreferences(updatedConfig);
  }

  Future<void> updateSpamReport({
    bool? isEnabled,
    int? lastTimeDismissedMilliseconds,
  }) async {
    final currentConfig = await getSpamReportConfig();
    final updatedConfig = currentConfig.copyWith(
      isEnabled: isEnabled,
      lastTimeDismissedMilliseconds: lastTimeDismissedMilliseconds,
    );
    await savePreferences(updatedConfig);
  }

  Future<SpamReportConfig> getSpamReportConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingSpamReportKey,
    );

    return jsonString == null
        ? SpamReportConfig.initial()
        : SpamReportConfig.fromJson(jsonDecode(jsonString));
  }

  Future<ThreadDetailConfig> getThreadConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingThreadKey,
    );

    return jsonString == null
        ? ThreadDetailConfig.initial()
        : ThreadDetailConfig.fromJson(jsonDecode(jsonString));
  }

  Future<TextFormattingMenuConfig> getTextFormattingMenuConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingTextFormattingMenuKey,
    );

    return jsonString == null
        ? TextFormattingMenuConfig.initial()
        : TextFormattingMenuConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateTextFormattingMenu({required bool isDisplayed}) async {
    final currentConfig = await getTextFormattingMenuConfig();
    final updatedConfig = currentConfig.copyWith(isDisplayed: isDisplayed);
    await savePreferences(updatedConfig);
  }
}

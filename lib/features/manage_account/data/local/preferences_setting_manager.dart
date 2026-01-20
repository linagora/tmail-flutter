import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/auto_sync_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/default_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/empty_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/open_email_in_new_window_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/quoted_content_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/sidebar_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

class PreferencesSettingManager {
  static const String _preferencesSettingKey = 'PREFERENCES_SETTING';
  static const String _preferencesSettingThreadKey =
      '${_preferencesSettingKey}_THREAD';
  static const String _preferencesSettingSpamReportKey =
      '${_preferencesSettingKey}_SPAM_REPORT';
  static const String _preferencesSettingTextFormattingMenuKey =
      '${_preferencesSettingKey}_TEXT_FORMATTING_MENU';
  static const String _preferencesSettingAIScribeKey =
      '${_preferencesSettingKey}_AI_SCRIBE';
  static const String _preferencesSettingLabelKey =
      '${_preferencesSettingKey}_LABEL';
  static const String _preferencesSettingOpenEmailInNewWindowKey =
      '${_preferencesSettingKey}_OPEN_EMAIL_IN_NEW_WINDOW';
  static const String _preferencesSettingAutoSyncKey =
      '${_preferencesSettingKey}_AUTO_SYNC';
  static const String _preferencesSettingQuotedContentKey =
      '${_preferencesSettingKey}_QUOTED_CONTENT';
  static const String _preferencesSettingSidebarKey =
      '${_preferencesSettingKey}_SIDEBAR';

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
          case _preferencesSettingAIScribeKey:
            return AIScribeConfig.fromJson(jsonDecoded);
          case _preferencesSettingLabelKey:
            return LabelConfig.fromJson(jsonDecoded);
          case _preferencesSettingOpenEmailInNewWindowKey:
            return OpenEmailInNewWindowConfig.fromJson(jsonDecoded);
          case _preferencesSettingAutoSyncKey:
            return AutoSyncConfig.fromJson(jsonDecoded);
          case _preferencesSettingQuotedContentKey:
            return QuotedContentConfig.fromJson(jsonDecoded);
          case _preferencesSettingSidebarKey:
            return SidebarConfig.fromJson(jsonDecoded);
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

  String _getPreferencesConfigKey(PreferencesConfig config) {
    if (config is ThreadDetailConfig) {
      return _preferencesSettingThreadKey;
    } else if (config is SpamReportConfig) {
      return _preferencesSettingSpamReportKey;
    } else if (config is TextFormattingMenuConfig) {
      return _preferencesSettingTextFormattingMenuKey;
    } else if (config is AIScribeConfig) {
      return _preferencesSettingAIScribeKey;
    } else if (config is LabelConfig) {
      return _preferencesSettingLabelKey;
    } else if (config is OpenEmailInNewWindowConfig) {
      return _preferencesSettingOpenEmailInNewWindowKey;
    } else if (config is AutoSyncConfig) {
      return _preferencesSettingAutoSyncKey;
    } else if (config is QuotedContentConfig) {
      return _preferencesSettingQuotedContentKey;
    } else if (config is SidebarConfig) {
      return _preferencesSettingSidebarKey;
    } else {
      return _preferencesSettingKey;
    }
  }

  Future<void> savePreferences(PreferencesConfig config) async {
    await _sharedPreferences.setString(
      _getPreferencesConfigKey(config),
      jsonEncode(config.toJson()),
    );
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

  Future<AIScribeConfig> getAIScribeConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingAIScribeKey,
    );

    return jsonString == null
        ? AIScribeConfig.initial()
        : AIScribeConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateAIScribe(bool isEnabled) async {
    final currentConfig = await getAIScribeConfig();
    final updatedConfig = currentConfig.copyWith(isEnabled: isEnabled);
    await savePreferences(updatedConfig);
  }

  Future<LabelConfig> getLabelConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingLabelKey,
    );

    return jsonString == null
        ? LabelConfig.initial()
        : LabelConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateLabel(bool isEnabled) async {
    final currentConfig = await getLabelConfig();
    final updatedConfig = currentConfig.copyWith(isEnabled: isEnabled);
    await savePreferences(updatedConfig);
  }

  Future<OpenEmailInNewWindowConfig> getOpenEmailInNewWindowConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingOpenEmailInNewWindowKey,
    );

    return jsonString == null
        ? OpenEmailInNewWindowConfig.initial()
        : OpenEmailInNewWindowConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateOpenEmailInNewWindow(bool isEnabled) async {
    final currentConfig = await getOpenEmailInNewWindowConfig();
    final updatedConfig = currentConfig.copyWith(isEnabled: isEnabled);
    await savePreferences(updatedConfig);
  }

  Future<AutoSyncConfig> getAutoSyncConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingAutoSyncKey,
    );

    return jsonString == null
        ? AutoSyncConfig.initial()
        : AutoSyncConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateAutoSync(bool isEnabled) async {
    final currentConfig = await getAutoSyncConfig();
    final updatedConfig = currentConfig.copyWith(isEnabled: isEnabled);
    await savePreferences(updatedConfig);
  }

  Future<QuotedContentConfig> getQuotedContentConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingQuotedContentKey,
    );

    return jsonString == null
        ? QuotedContentConfig.initial()
        : QuotedContentConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateQuotedContent(bool isHiddenByDefault) async {
    final currentConfig = await getQuotedContentConfig();
    final updatedConfig = currentConfig.copyWith(isHiddenByDefault: isHiddenByDefault);
    await savePreferences(updatedConfig);
  }

  Future<SidebarConfig> getSidebarConfig() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(
      _preferencesSettingSidebarKey,
    );

    return jsonString == null
        ? SidebarConfig.initial()
        : SidebarConfig.fromJson(jsonDecode(jsonString));
  }

  Future<void> updateSidebar(bool isExpanded) async {
    final currentConfig = await getSidebarConfig();
    final updatedConfig = currentConfig.copyWith(isExpanded: isExpanded);
    await savePreferences(updatedConfig);
  }
}

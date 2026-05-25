import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/default_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/empty_preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

class PreferencesSettingManager {
  static const _storagePrefix = 'PREFERENCES_SETTING';

  static String _storageKey(String suffix) => '${_storagePrefix}_$suffix';

  // Add one entry here when introducing a new PreferencesConfig subclass.
  static final Map<String, PreferencesConfig Function(Map<String, dynamic>)>
      _configFactories = Map.unmodifiable({
    _storageKey(ThreadDetailConfig.keySuffix): ThreadDetailConfig.fromJson,
    _storageKey(SpamReportConfig.keySuffix): SpamReportConfig.fromJson,
    _storageKey(TextFormattingMenuConfig.keySuffix): TextFormattingMenuConfig.fromJson,
    _storageKey(AIScribeConfig.keySuffix): AIScribeConfig.fromJson,
    _storageKey(LabelConfig.keySuffix): LabelConfig.fromJson,
  });

  const PreferencesSettingManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<PreferencesSetting> loadPreferences() async {
    await _sharedPreferences.reload();

    final listConfigs = _sharedPreferences
        .getKeys()
        .where((key) => key.startsWith(_storagePrefix))
        .map((key) {
          final jsonString = _sharedPreferences.getString(key);
          if (jsonString == null) return EmptyPreferencesConfig();
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            final factory = _configFactories[key];
            return factory != null ? factory(json) : DefaultPreferencesConfig.fromJson(json);
          } catch (_) {
            return EmptyPreferencesConfig();
          }
        })
        .toList();

    if (listConfigs.isEmpty) {
      return PreferencesSetting.initial();
    }

    return PreferencesSetting(listConfigs);
  }

  // SpamReportConfig is read-merge-written to preserve lastTimeDismissedMilliseconds.
  Future<void> savePreferences(PreferencesConfig config) async {
    if (config is SpamReportConfig) {
      await updateSpamReport(isEnabled: config.isEnabled);
      return;
    }
    await _sharedPreferences.setString(
      _storageKey(config.configKey),
      jsonEncode(config.toJson()),
    );
  }

  Future<SpamReportConfig> getSpamReportConfig() => _readConfig(
        key: _storageKey(SpamReportConfig.keySuffix),
        defaultFactory: SpamReportConfig.initial,
        fromJson: SpamReportConfig.fromJson,
      );

  // Used by spam-report logic that runs outside the preferences toggle flow.
  Future<void> updateSpamReport({
    bool? isEnabled,
    int? lastTimeDismissedMilliseconds,
  }) async {
    final current = await getSpamReportConfig();
    await _sharedPreferences.setString(
      _storageKey(SpamReportConfig.keySuffix),
      jsonEncode(current.copyWith(
        isEnabled: isEnabled,
        lastTimeDismissedMilliseconds: lastTimeDismissedMilliseconds,
      ).toJson()),
    );
  }

  Future<ThreadDetailConfig> getThreadConfig() => _readConfig(
        key: _storageKey(ThreadDetailConfig.keySuffix),
        defaultFactory: ThreadDetailConfig.initial,
        fromJson: ThreadDetailConfig.fromJson,
      );

  Future<TextFormattingMenuConfig> getTextFormattingMenuConfig() => _readConfig(
        key: _storageKey(TextFormattingMenuConfig.keySuffix),
        defaultFactory: TextFormattingMenuConfig.initial,
        fromJson: TextFormattingMenuConfig.fromJson,
      );

  Future<void> updateTextFormattingMenu({required bool isDisplayed}) async {
    final current = await getTextFormattingMenuConfig();
    await savePreferences(current.copyWith(isDisplayed: isDisplayed));
  }

  Future<AIScribeConfig> getAIScribeConfig() => _readConfig(
        key: _storageKey(AIScribeConfig.keySuffix),
        defaultFactory: AIScribeConfig.initial,
        fromJson: AIScribeConfig.fromJson,
      );

  Future<LabelConfig> getLabelConfig() => _readConfig(
        key: _storageKey(LabelConfig.keySuffix),
        defaultFactory: LabelConfig.initial,
        fromJson: LabelConfig.fromJson,
      );

  Future<T> _readConfig<T extends PreferencesConfig>({
    required String key,
    required T Function() defaultFactory,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    await _sharedPreferences.reload();
    final jsonString = _sharedPreferences.getString(key);
    if (jsonString == null) return defaultFactory();
    try {
      return fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return defaultFactory();
    }
  }
}

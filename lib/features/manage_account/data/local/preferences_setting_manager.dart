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

    final preferenceKeys = _sharedPreferences
        .getKeys()
        .where((key) => key.startsWith('${_storagePrefix}_'))
        .toList()
      ..sort();

    if (preferenceKeys.isEmpty) {
      return PreferencesSetting.initial();
    }

    return PreferencesSetting(preferenceKeys.map(_parseConfig).toList());
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

  PreferencesConfig _parseConfig(String key) {
    final jsonString = _sharedPreferences.getString(key);
    if (jsonString == null) return EmptyPreferencesConfig();
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final factory = _configFactories[key];
      return factory != null ? factory(json) : DefaultPreferencesConfig.fromJson(json);
    } catch (_) {
      return EmptyPreferencesConfig();
    }
  }

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

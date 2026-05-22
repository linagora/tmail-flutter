import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class ManageAccountDataSourceImpl extends ManageAccountDataSource {

  final LanguageCacheManager _languageCacheManager;
  final PreferencesSettingManager _preferencesSettingManager;
  final ExceptionThrower _exceptionThrower;

  ManageAccountDataSourceImpl(
    this._languageCacheManager,
    this._preferencesSettingManager,
    this._exceptionThrower
  );

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return Future.sync(() async {
      return await _languageCacheManager.persistLanguage(localeCurrent);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<PreferencesSetting> toggleLocalSettingsState(PreferencesConfig preferencesConfig) {
    return Future.sync(() async {
      await _preferencesSettingManager.savePreferences(preferencesConfig);
      return await _preferencesSettingManager.loadPreferences();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<PreferencesSetting> getLocalSettings() {
    return Future.sync(() async {
      return await _preferencesSettingManager.loadPreferences();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<AIScribeConfig> getAiScribeConfigLocalSettings() {
    return Future.sync(() async {
      return await _preferencesSettingManager.getAIScribeConfig();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> getLabelSettingState() {
    return Future.sync(() async {
      final labelConfig = await _preferencesSettingManager.getLabelConfig();
      return labelConfig.isEnabled;
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> getExperimentalModeEnabled() {
    return Future.sync(() => _preferencesSettingManager.getExperimentalModeEnabled())
        .catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> enableExperimentalMode() {
    return Future.sync(() => _preferencesSettingManager.enableExperimentalMode())
        .catchError(_exceptionThrower.throwException);
  }
}

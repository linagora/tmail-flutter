import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ManageAccountDataSourceImpl extends ManageAccountDataSource {

  final LanguageCacheManager _languageCacheManager;
  final PreferencesSettingManager _preferencesSettingManager;
  final SettingCacheManager _settingCacheManager;
  final ExceptionThrower _exceptionThrower;

  ManageAccountDataSourceImpl(
    this._languageCacheManager,
    this._preferencesSettingManager,
    this._settingCacheManager,
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
      if (preferencesConfig is ThreadDetailConfig) {
        await _preferencesSettingManager.updateThread(
          preferencesConfig.isEnabled,
        );
      } else if (preferencesConfig is SpamReportConfig) {
        await _preferencesSettingManager.updateSpamReport(
          isEnabled: preferencesConfig.isEnabled,
        );
      } else if (preferencesConfig is TextFormattingMenuConfig) {
        await _preferencesSettingManager.updateTextFormattingMenu(
          isDisplayed: preferencesConfig.isDisplayed,
        );
      } else if (preferencesConfig is AIScribeConfig) {
        await _preferencesSettingManager.updateAIScribe(
          preferencesConfig.isEnabled,
        );
      } else if (preferencesConfig is LabelConfig) {
        await _preferencesSettingManager.updateLabel(
          preferencesConfig.isEnabled,
        );
      } else {
        await _preferencesSettingManager.savePreferences(
          preferencesConfig,
        );
      }
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
  Future<bool> getLabelVisibility() {
    return Future.sync(() {
      return _settingCacheManager.getLabelVisibility();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveLabelVisibility(bool visible) {
    return Future.sync(() async {
      return await _settingCacheManager.saveLabelVisibility(visible);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> getLabelSettingState() {
    return Future.sync(() async {
      final labelConfig = await _preferencesSettingManager.getLabelConfig();
      return labelConfig.isEnabled;
    }).catchError(_exceptionThrower.throwException);
  }
}
import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/local_setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ManageAccountDataSourceImpl extends ManageAccountDataSource {

  final LanguageCacheManager _languageCacheManager;
  final LocalSettingCacheManager _localSettingCacheManager;
  final ExceptionThrower _exceptionThrower;

  ManageAccountDataSourceImpl(
    this._languageCacheManager,
    this._localSettingCacheManager,
    this._exceptionThrower
  );

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return Future.sync(() async {
      return await _languageCacheManager.persistLanguage(localeCurrent);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> updateLocalSettings(
    Map<SupportedLocalSetting, LocalSettingOptions?> localSettings,
  ) {
    return Future.sync(() async {
      return await _localSettingCacheManager.update(localSettings);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Map<SupportedLocalSetting, LocalSettingOptions?>> getLocalSettings(
    List<SupportedLocalSetting> supportedLocalSettings,
  ) {
    return Future.sync(() async {
      return await _localSettingCacheManager.get(supportedLocalSettings);
    }).catchError(_exceptionThrower.throwException);
  }
}
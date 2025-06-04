import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/preferences_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class PreferencesDataSourceImpl extends PreferencesDataSource {

  final LanguageCacheManager _languageCacheManager;
  final ExceptionThrower _exceptionThrower;

  PreferencesDataSourceImpl(
    this._languageCacheManager,
    this._exceptionThrower
  );

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return Future.sync(() async {
      return await _languageCacheManager.persistLanguage(localeCurrent);
    }).catchError(_exceptionThrower.throwException);
  }
}
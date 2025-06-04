import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/preferences_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/preferences_repository.dart';

class PreferencesRepositoryImpl extends PreferencesRepository {

  final PreferencesDataSource dataSource;

  PreferencesRepositoryImpl(this.dataSource);

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return dataSource.persistLanguage(localeCurrent);
  }
}
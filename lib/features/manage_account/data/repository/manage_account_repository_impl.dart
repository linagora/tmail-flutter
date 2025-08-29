import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/preferences_root.dart';

class ManageAccountRepositoryImpl extends ManageAccountRepository {

  final ManageAccountDataSource dataSource;

  ManageAccountRepositoryImpl(this.dataSource);

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return dataSource.persistLanguage(localeCurrent);
  }

  @override
  Future<void> updateLocalSettings(PreferencesRoot preferencesRoot) {
    return dataSource.updateLocalSettings(preferencesRoot);
  }

  @override
  Future<PreferencesRoot> getLocalSettings() {
    return dataSource.getLocalSettings();
  }
}
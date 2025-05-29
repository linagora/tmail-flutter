import 'dart:ui';

import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class ManageAccountRepositoryImpl extends ManageAccountRepository {

  final ManageAccountDataSource dataSource;

  ManageAccountRepositoryImpl(this.dataSource);

  @override
  Future<void> persistLanguage(Locale localeCurrent) {
    return dataSource.persistLanguage(localeCurrent);
  }

  @override
  Future<void> updateLocalSettings(LocalSettingOptions localSettingOptions) {
    return dataSource.updateLocalSettings(localSettingOptions);
  }

  @override
  Future<LocalSettingOptions> getLocalSettings() {
    return dataSource.getLocalSettings();
  }
}
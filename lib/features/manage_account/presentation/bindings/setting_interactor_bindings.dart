import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/main/exceptions/cache_exception_thrower.dart';

class SettingInteractorBindings extends InteractorsBindings {
  @override
  void bindingsDataSource() {
    Get.lazyPut<ManageAccountDataSource>(
      () => Get.find<ManageAccountDataSourceImpl>(),
    );
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(
      () => ManageAccountDataSourceImpl(
        Get.find<LanguageCacheManager>(),
        Get.find<PreferencesSettingManager>(),
        Get.find<CacheExceptionThrower>(),
      ),
    );
  }

  @override
  void bindingsInteractor() {}

  @override
  void bindingsRepository() {
    Get.lazyPut<ManageAccountRepository>(
      () => Get.find<ManageAccountRepositoryImpl>(),
    );
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(
      () => ManageAccountRepositoryImpl(Get.find<ManageAccountDataSource>()),
    );
  }
}

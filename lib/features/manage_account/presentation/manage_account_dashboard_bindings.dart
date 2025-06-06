import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/preferences_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/preferences_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/preferences_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/preferences_repository.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings/settings_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_bindings.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class ManageAccountDashBoardBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    SettingsBindings().dependencies();
    ManageAccountMenuBindings().dependencies();
    ProfileBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.put(ManageAccountDashBoardController());
  }

  @override
  void bindingsDataSource() {
    Get.lazyPut<PreferencesDataSource>(() => Get.find<PreferencesDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => PreferencesDataSourceImpl(
      Get.find<LanguageCacheManager>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {}

  @override
  void bindingsRepository() {
    Get.lazyPut<PreferencesRepository>(() => Get.find<PreferencesRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => PreferencesRepositoryImpl(Get.find<PreferencesDataSource>()));
  }
}
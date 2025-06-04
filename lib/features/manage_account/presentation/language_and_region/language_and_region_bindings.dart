import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_to_server_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_interactors_bindings.dart';
import 'package:tmail_ui_user/features/server_settings/domain/repository/server_settings_repository.dart';

class LanguageAndRegionBindings extends BaseBindings {

  @override
  void dependencies() {
    PreferencesInteractorsBindings().dependencies();

    super.dependencies();
  }
  
  @override
  void bindingsController() {
    Get.lazyPut(() => LanguageAndRegionController(
      Get.find<SaveLanguageInteractor>(),
      Get.find<SaveLanguageToServerSettingsInteractor>(),
    ));
  }
  
  @override
  void bindingsDataSource() {
  }
  
  @override
  void bindingsDataSourceImpl() {
  }
  
  @override
  void bindingsInteractor() {
    Get.lazyPut(
      () => SaveLanguageToServerSettingsInteractor(Get.find<ServerSettingsRepository>()),
    );
  }
  
  @override
  void bindingsRepository() {
  }
  
  @override
  void bindingsRepositoryImpl() {
  }
}
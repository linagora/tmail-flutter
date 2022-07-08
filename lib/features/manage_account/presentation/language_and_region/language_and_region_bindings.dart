import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_app_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';

class LanguageAndRegionBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => LanguageAndRegionController(Get.find<SaveLanguageAppInteractor>()));
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => SaveLanguageAppInteractor(Get.find<ManageAccountRepository>()));
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }
}
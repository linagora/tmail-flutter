import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/configuration/configuration_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/configuration/vacation/vacation_bindings.dart';

class ConfigurationBindings extends BaseBindings {

  @override
  void dependencies() {
    super.dependencies();
    VacationBindings().dependencies();
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => ConfigurationController());
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }
}
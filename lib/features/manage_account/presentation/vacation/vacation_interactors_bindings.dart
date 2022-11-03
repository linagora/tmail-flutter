import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/vacation_data_source.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/vacation_data_source_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/vacation_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/vacation_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/vacation_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class VacationInteractorsBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<VacationDataSource>(() => Get.find<VacationDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => VacationDataSourceImpl(
      Get.find<VacationAPI>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllVacationInteractor(Get.find<VacationRepository>()));
    Get.lazyPut(() => UpdateVacationInteractor(Get.find<VacationRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<VacationRepository>(() => Get.find<VacationRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => VacationRepositoryImpl(Get.find<VacationDataSource>()));
  }
}
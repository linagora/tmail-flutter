import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';

class VacationBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => VacationController(
        Get.find<GetAllVacationInteractor>(),
        Get.find<UpdateVacationInteractor>(),
        Get.find<VerifyNameInteractor>()));
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllVacationInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => UpdateVacationInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => VerifyNameInteractor());
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }
}
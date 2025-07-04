import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';

class VacationControllerBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => VerifyNameInteractor());
    Get.put(VacationController(Get.find<UpdateVacationInteractor>()));
  }
}
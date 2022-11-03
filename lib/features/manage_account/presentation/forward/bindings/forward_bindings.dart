import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';

class ForwardBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => VerifyNameInteractor());
    Get.lazyPut(() => ForwardController(Get.find<VerifyNameInteractor>()));
  }
}
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';

class ForwardBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => ForwardController());
  }
}
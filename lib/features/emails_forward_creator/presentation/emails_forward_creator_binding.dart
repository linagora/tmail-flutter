import 'package:get/get.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/emails_forward_creator_controller.dart';

class EmailsForwardCreatorBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => EmailsForwardCreatorController());
  }

  void dispose() {
    Get.delete<EmailsForwardCreatorController>();
  }
}
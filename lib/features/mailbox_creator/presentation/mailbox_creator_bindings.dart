import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_controller.dart';

class MailboxCreatorBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => MailboxCreatorController());
  }
}
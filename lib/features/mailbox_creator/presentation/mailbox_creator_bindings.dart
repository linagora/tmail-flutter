import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/mailbox_creator_controller.dart';

class MailboxCreatorBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => TreeBuilder());
    Get.lazyPut(() => MailboxCreatorController(Get.find<TreeBuilder>()));
  }
}
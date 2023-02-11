import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/mailbox_visibility_controller.dart';

class MailboxVisibilityBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => MailboxVisibilityController(
      Get.find<TreeBuilder>(),
      Get.find<VerifyNameInteractor>()
    ));
    _bindingsUtils();
  }

  void _bindingsUtils() {
    Get.lazyPut(() => TreeBuilder());
  }
}
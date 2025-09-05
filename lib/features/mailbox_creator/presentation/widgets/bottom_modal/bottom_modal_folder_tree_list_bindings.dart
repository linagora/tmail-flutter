import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/widgets/bottom_modal/bottom_modal_folder_tree_list_controller.dart';

class BottomModalFolderTreeListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BottomModalFolderTreeListController());
  }

  void dispose() {
    Get.delete<BottomModalFolderTreeListController>();
  }
}

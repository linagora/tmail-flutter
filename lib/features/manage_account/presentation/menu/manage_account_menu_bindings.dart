import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/manage_account_menu_controller.dart';

class ManageAccountMenuBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(ManageAccountMenuController());
  }
}
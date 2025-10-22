import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_controller.dart';

class StorageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StorageController());
  }
}

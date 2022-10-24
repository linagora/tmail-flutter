
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/contact/presentation/contact_controller.dart';

class ContactBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => ContactController());
  }

  void dispose() {
    Get.delete<ContactController>();
  }
}
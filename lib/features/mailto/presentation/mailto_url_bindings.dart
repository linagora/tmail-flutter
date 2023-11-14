import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailto/presentation/mailto_url_controller.dart';

class MailtoUrlBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => MailtoUrlController());
  }
}
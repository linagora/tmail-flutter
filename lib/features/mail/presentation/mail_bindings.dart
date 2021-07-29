import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mail/presentation/mail_controller.dart';

class MailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MailController(Get.find<ResponsiveUtils>()));
  }
}
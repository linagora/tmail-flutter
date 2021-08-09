import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';

class EmailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmailController(Get.find<ResponsiveUtils>()));
  }
}
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_controller.dart';

class TwakeWelcomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TwakeWelcomeController());
  }
}
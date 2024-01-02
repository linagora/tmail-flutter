import 'package:get/get.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_id/twake_id_controller.dart';

class TwakeIdBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TwakeIdController());
  }
}
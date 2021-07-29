import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

class ThreadBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ThreadController(Get.find<ResponsiveUtils>()));
  }
}
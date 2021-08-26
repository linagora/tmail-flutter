import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

class ComposerBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ComposerController());
  }
}
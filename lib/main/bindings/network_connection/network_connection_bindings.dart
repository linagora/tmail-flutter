import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart';

class NetWorkConnectionBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(NetworkConnectionController(
      Get.find<Connectivity>(),
      Get.find<ImagePaths>(),
      Get.find<AppToast>(),
    ));
  }
}
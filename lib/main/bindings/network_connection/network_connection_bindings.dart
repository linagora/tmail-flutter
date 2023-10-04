import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';

class NetWorkConnectionBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(NetworkConnectionController(Get.find<Connectivity>()));
  }
}
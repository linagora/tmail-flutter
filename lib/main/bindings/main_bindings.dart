import 'package:get/get.dart';
import 'package:tmail_ui_user/main/bindings/core/core_bindings.dart';
import 'package:tmail_ui_user/main/bindings/local/local_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network/network_bindings.dart';

class MainBindings extends Bindings {
  @override
  Future dependencies() async {
    await CoreBindings().dependencies();
    NetworkBindings().dependencies();
    LocalBindings().dependencies();
  }
}
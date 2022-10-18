import 'package:get/get.dart';
import 'package:tmail_ui_user/main/bindings/core/core_bindings.dart';
import 'package:tmail_ui_user/main/bindings/credential/credential_bindings.dart';
import 'package:tmail_ui_user/main/bindings/local/local_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network/network_bindings.dart';
import 'package:tmail_ui_user/main/bindings/network/network_isolate_binding.dart';
import 'package:tmail_ui_user/main/bindings/network_connection/network_connection_bindings.dart';
import 'package:tmail_ui_user/main/bindings/session/session_bindings.dart';

class MainBindings extends Bindings {
  @override
  Future dependencies() async {
    await CoreBindings().dependencies();
    LocalBindings().dependencies();
    NetworkBindings().dependencies();
    NetworkIsolateBindings().dependencies();
    CredentialBindings().dependencies();
    NetWorkConnectionBindings().dependencies();
    SessionBindings().dependencies();
  }
}
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identity_bindings.dart';

class ProfileBindings extends Bindings {

  @override
  void dependencies() {
    IdentityBindings().dependencies();
  }
}
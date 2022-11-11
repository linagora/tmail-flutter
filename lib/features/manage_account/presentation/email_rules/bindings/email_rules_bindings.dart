import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';

class EmailRulesBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => EmailRulesController());
  }
}
import 'package:get/get.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';

class EmailRulesController extends BaseController {

  final listEmailRule = <TMailRule>[].obs;

  EmailRulesController();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {}

  void goToCreateNewRule() {
    //TODO: goToCreateNewRule
  }

  void editEmailRule(TMailRule rule){
    //TODO: editEmailRule
  }

  void deleteEmailRule(TMailRule rule){
    //TODO: deleteEmailRule
  }
}

import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:rule_filter/rule_filter/tmail_rule.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_rules_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';

class EmailRulesController extends BaseController {
  final listEmailRule = <TMailRule>[].obs;
  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final GetAllRulesInteractor _getAllRulesInteractor;
  late Worker accountIdWorker;

  EmailRulesController(this._getAllRulesInteractor);

  void _clearWorker() {
    accountIdWorker.call();
  }

  @override
  void onDone() {
    viewState.value.fold(
            (failure) {},
            (success) {
          if (success is GetAllRulesSuccess) {
            if (success.rules?.isNotEmpty == true) {
              listEmailRule.addAll(success.rules!);
            }
          }
        }
    );
  }

  @override
  void onError(error) {}

  @override
  void onInit() {
    _getAllRules(_accountDashBoardController.accountId.value!);
    super.onInit();
  }

  @override
  void onClose() {
    _clearWorker();
    super.onClose();
  }

  void goToCreateNewRule() {
    //TODO: goToCreateNewRule
  }

  void editEmailRule(TMailRule rule) {
    //TODO: editEmailRule
  }

  void deleteEmailRule(TMailRule rule) {
    //TODO: deleteEmailRule
  }

  void _getAllRules(AccountId accountId) {
    consumeState(_getAllRulesInteractor.execute(accountId));
  }
}

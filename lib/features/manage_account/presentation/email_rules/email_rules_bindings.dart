import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_email_rule_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_controller.dart';

class EmailRulesBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => EmailRulesController(
      Get.find<GetAllRulesInteractor>(),
      Get.find<DeleteEmailRuleInteractor>(),
      Get.find<CreateNewEmailRuleFilterInteractor>(),
      Get.find<EditEmailRuleFilterInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllRulesInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => DeleteEmailRuleInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => CreateNewEmailRuleFilterInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => EditEmailRuleFilterInteractor(Get.find<ManageAccountRepository>()));
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}
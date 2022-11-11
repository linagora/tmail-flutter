import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/rule_filter_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/rule_filter_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/network/rule_filter_api.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/rule_filter_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/rule_filter_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_email_rule_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_rules_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception_thrower.dart';

class EmailRulesInteractorBindings extends InteractorsBindings {

  @override
  void bindingsDataSource() {
    Get.lazyPut<RuleFilterDataSource>(() => Get.find<RuleFilterDataSourceImpl>());
  }

  @override
  void bindingsDataSourceImpl() {
    Get.lazyPut(() => RuleFilterDataSourceImpl(
      Get.find<RuleFilterAPI>(),
      Get.find<RemoteExceptionThrower>()));
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetAllRulesInteractor(Get.find<RuleFilterRepository>()));
    Get.lazyPut(() => DeleteEmailRuleInteractor(Get.find<RuleFilterRepository>()));
    Get.lazyPut(() => CreateNewEmailRuleFilterInteractor(Get.find<RuleFilterRepository>()));
    Get.lazyPut(() => EditEmailRuleFilterInteractor(Get.find<RuleFilterRepository>()));
  }

  @override
  void bindingsRepository() {
    Get.lazyPut<RuleFilterRepository>(() => Get.find<RuleFilterRepositoryImpl>());
  }

  @override
  void bindingsRepositoryImpl() {
    Get.lazyPut(() => RuleFilterRepositoryImpl(Get.find<RuleFilterDataSource>()));
  }
}
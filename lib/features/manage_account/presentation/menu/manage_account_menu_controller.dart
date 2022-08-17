
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

class ManageAccountMenuController extends BaseController {

  final dashBoardController = Get.find<ManageAccountDashBoardController>();

  late Worker sessionWorker;

  final listAccountMenuItem = RxList<AccountMenuItem>([
    AccountMenuItem.profiles,
    AccountMenuItem.languageAndRegion,
    AccountMenuItem.vacation,
  ]);

  void _initWorker() {
    sessionWorker = ever(dashBoardController.sessionCurrent, (_) {
      _createListAccountMenu();
    });
  }

  void _clearWorker() {
    sessionWorker.call();
  }

  @override
  void onInit() {
    _initWorker();
    _createListAccountMenu();
    super.onInit();
  }

  void _createListAccountMenu(){
    listAccountMenuItem.clear();
    listAccountMenuItem.add(AccountMenuItem.profiles);
    if (dashBoardController.checkAvailableRuleFilterInSession()) {
      listAccountMenuItem.add(AccountMenuItem.emailRules);
    }
    if (dashBoardController.checkAvailableForwardInSession()) {
      listAccountMenuItem.add(AccountMenuItem.forward);
    }
    listAccountMenuItem.add(AccountMenuItem.languageAndRegion);
    listAccountMenuItem.add(AccountMenuItem.vacation);
  }

  @override
  void onClose() {
    _clearWorker();
    super.onClose();
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {
  }

  void selectAccountMenuItem(AccountMenuItem newAccountMenuItem) {
    dashBoardController.selectAccountMenuItem(newAccountMenuItem);
  }

  void backToMailboxDashBoard(BuildContext context) {
    dashBoardController.backToMailboxDashBoard(context);
  }
}
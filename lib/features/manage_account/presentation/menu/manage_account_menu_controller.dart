
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

class ManageAccountMenuController extends BaseController {

  final dashBoardController = Get.find<ManageAccountDashBoardController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  late Worker sessionWorker;

  final listAccountMenuItem = RxList<AccountMenuItem>([
    AccountMenuItem.profiles,
    AccountMenuItem.languageAndRegion,
  ]);

  void _initWorker() {
    sessionWorker = ever(dashBoardController.sessionCurrent, (_) {
      _createListAccountMenuItemWithEmailRule();
    });
  }

  void _clearWorker() {
    sessionWorker.call();
  }

  @override
  void onInit() {
    _initWorker();
    _createListAccountMenuItemWithEmailRule();
    super.onInit();
  }

  _createListAccountMenuItemWithEmailRule(){
    if (dashBoardController.checkAvailableRuleFilterInSession()) {
      listAccountMenuItem.clear();
      listAccountMenuItem.addAll([
        AccountMenuItem.profiles,
        AccountMenuItem.emailRules,
        AccountMenuItem.languageAndRegion,
      ]);
    }
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

class ManageAccountMenuController extends BaseController {

  final dashBoardController = Get.find<ManageAccountDashBoardController>();

  final listAccountMenuItem = <AccountMenuItem>[
    AccountMenuItem.profiles,
    AccountMenuItem.emailRules,
    AccountMenuItem.languageAndRegion,
  ];

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
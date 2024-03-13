
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountMenuController extends GetxController {

  final dashBoardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  final listAccountMenuItem = RxList<AccountMenuItem>([
    AccountMenuItem.profiles,
    AccountMenuItem.mailboxVisibility,
    AccountMenuItem.languageAndRegion,
  ]);

  void _registerObxStreamListener() {
    ever(dashBoardController.accountId, (accountId) {
      if (accountId != null) {
        _createListAccountMenu();
      }
    });
  }

  @override
  void onInit() {
    _registerObxStreamListener();
    super.onInit();
  }

  void _createListAccountMenu() {
    final newListMenuSetting = [
      AccountMenuItem.profiles,
      if (dashBoardController.isRuleFilterCapabilitySupported)
        AccountMenuItem.emailRules,
      if (dashBoardController.isServerSettingsCapabilitySupported)
        AccountMenuItem.alwaysReadReceipt,
      if (dashBoardController.isForwardCapabilitySupported)
        AccountMenuItem.forward,
      if (dashBoardController.isVacationCapabilitySupported)
        AccountMenuItem.vacation,
      AccountMenuItem.mailboxVisibility,
      AccountMenuItem.languageAndRegion
    ];
    listAccountMenuItem.value = newListMenuSetting;

    if (listAccountMenuItem.isNotEmpty) {
      if (currentContext != null && responsiveUtils.isWebDesktop(currentContext!)) {
        selectAccountMenuItem(listAccountMenuItem.first);
      } else {
        selectAccountMenuItem(AccountMenuItem.none);
      }
    }
  }

  void selectAccountMenuItem(AccountMenuItem newAccountMenuItem) {
    dashBoardController.selectAccountMenuItem(newAccountMenuItem);
  }

  void backToMailboxDashBoard(BuildContext context) {
    dashBoardController.backToMailboxDashBoard(context: context);
  }
}
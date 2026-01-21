import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/model/account_menu_items_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountMenuController extends GetxController
    with ContactSupportMixin {
  final dashBoardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  late final AccountMenuItemsBuilder _menuItemsBuilder;
  late Worker _quotaRxWorker;

  final listAccountMenuItem = RxList<AccountMenuItem>([
    AccountMenuItem.profiles,
    AccountMenuItem.mailboxVisibility,
    if (PlatformInfo.isWeb) AccountMenuItem.keyboardShortcuts,
  ]);

  @override
  void onInit() {
    _menuItemsBuilder = AccountMenuItemsBuilder(dashBoardController);
    _registerObxStreamListener();
    super.onInit();
  }

  void _registerObxStreamListener() {
    ever(dashBoardController.accountId, (accountId) {
      if (accountId != null) {
        _refreshMenuItems();
      }
    });

    _quotaRxWorker = ever(
      dashBoardController.octetsQuota,
      (octetsQuota) {
        if (_menuItemsBuilder.canAddStorage()) {
          _addStorageToMenuList();
        }
      },
    );
  }

  void _refreshMenuItems() {
    listAccountMenuItem.value = _menuItemsBuilder.buildMenuItems();
    _selectInitialMenuItem();
  }

  void _selectInitialMenuItem() {
    if (listAccountMenuItem.isEmpty) return;

    final shouldAutoSelect =
        currentContext != null && responsiveUtils.isWebDesktop(currentContext!);

    selectAccountMenuItem(
      shouldAutoSelect ? listAccountMenuItem.first : AccountMenuItem.none,
    );
  }

  void selectAccountMenuItem(AccountMenuItem newAccountMenuItem) {
    dashBoardController.selectAccountMenuItem(newAccountMenuItem);
  }

  void backToMailboxDashBoard(BuildContext context) {
    dashBoardController.backToMailboxDashBoard(context: context);
  }

  void _addStorageToMenuList() {
    if (!listAccountMenuItem.contains(AccountMenuItem.storage)) {
      listAccountMenuItem.add(AccountMenuItem.storage);
    }

    _reselectedCurrentMenuItem();
  }

  void _reselectedCurrentMenuItem() {
    final selectedMenu = dashBoardController.selectedMenu;
    if (selectedMenu != null) {
      dashBoardController.selectAccountMenuItem(selectedMenu);
    }
  }

  @override
  void onClose() {
    _quotaRxWorker.dispose();
    super.onClose();
  }
}

import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountMenuController extends GetxController with ContactSupportMixin {

  final dashBoardController = Get.find<ManageAccountDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();

  final listAccountMenuItem = RxList<AccountMenuItem>([
    AccountMenuItem.profiles,
    AccountMenuItem.mailboxVisibility,
    if (PlatformInfo.isWeb)
      AccountMenuItem.keyboardShortcuts,
  ]);

  late Worker _quotaRxWorker;

  void _registerObxStreamListener() {
    ever(dashBoardController.accountId, (accountId) {
      if (accountId != null) {
        _createListAccountMenu();
      }
    });

    _quotaRxWorker = ever(
      dashBoardController.octetsQuota,
      (octetsQuota) {
        if (octetsQuota != null && octetsQuota.storageAvailable) {
          _addStorageToMenuList();
        }
      },
    );
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
        AccountMenuItem.preferences,
      if (dashBoardController.isForwardCapabilitySupported)
        AccountMenuItem.forward,
      if (dashBoardController.isVacationCapabilitySupported)
        AccountMenuItem.vacation,
      AccountMenuItem.mailboxVisibility,
      if (dashBoardController.isLanguageSettingDisplayed)
        AccountMenuItem.languageAndRegion,
      if (PlatformInfo.isWeb)
        AccountMenuItem.keyboardShortcuts,
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

  void _addStorageToMenuList() {
    listAccountMenuItem.add(AccountMenuItem.storage);

    if (dashBoardController.selectedMenu != null) {
      dashBoardController.selectAccountMenuItem(
        dashBoardController.selectedMenu!,
      );
    }
  }

  @override
  void onClose() {
    _quotaRxWorker.dispose();
    super.onClose();
  }
}
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/delegation_settings_entry.dart';
import 'package:tmail_ui_user/features/base/mixin/contact_support_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
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
  ProviderSubscription<PreferencesSetting>? _localSettingsSubscription;

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
    _localSettingsSubscription = appProviderContainer.listen(
      localSettingsProvider,
      (_, __) {
        _syncDelegationMenuItem();
        _openDelegationRequestedWhileHidden();
      },
    );
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
    _syncDelegationMenuItem();

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
    _syncDelegationMenuItem();

    if (dashBoardController.selectedMenu != null) {
      dashBoardController.selectAccountMenuItem(
        dashBoardController.selectedMenu!,
      );
    }
  }

  void _syncDelegationMenuItem() {
    final isDisplayed = dashBoardController.isDelegationSettingDisplayed;
    final items = settingsMenuWithDelegationEntry(
      listAccountMenuItem,
      isDelegationEntryShown: isDisplayed,
    );
    listAccountMenuItem.value = items;

    if (!isDisplayed &&
        dashBoardController.accountMenuItemSelected.value == AccountMenuItem.delegation) {
      final isWebDesktop = currentContext != null && responsiveUtils.isWebDesktop(currentContext!);
      selectAccountMenuItem(isWebDesktop ? items.first : AccountMenuItem.none);
    }

    if (!isDisplayed && dashBoardController.selectedMenu == AccountMenuItem.delegation) {
      dashBoardController.selectedMenu = null;
    }
  }

  void _openDelegationRequestedWhileHidden() {
    if (dashBoardController.takeDelegationRequestedWhileHidden() &&
        dashBoardController.isDelegationSettingDisplayed) {
      dashBoardController.selectedMenu = AccountMenuItem.delegation;
      selectAccountMenuItem(AccountMenuItem.delegation);
    }
  }

  @override
  void onClose() {
    _localSettingsSubscription?.close();
    _quotaRxWorker.dispose();
    super.onClose();
  }
}
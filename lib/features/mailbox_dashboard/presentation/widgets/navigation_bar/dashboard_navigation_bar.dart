import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_capabilities_provider.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/navigation_bar/navigation_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/search_input_form_widget.dart';

/// The web dashboard navigation bar, with its avatar menu on my own account.
class DashboardNavigationBar extends ConsumerWidget {
  final _dashboardController = Get.find<MailboxDashBoardController>();

  DashboardNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canOpenSettings = ref.watch(shownAccountCapabilitiesProvider).canOpenSettings;
    return Obx(() {
      final accountId = _dashboardController.accountId.value;
      String accountDisplayName = _dashboardController.ownEmailAddress.value;
      final contactSupportCapability = accountId != null
        ? _dashboardController.sessionCurrent?.getContactSupportCapability(accountId)
        : null;
      if (accountDisplayName.trim().isEmpty) {
        accountDisplayName = _dashboardController
          .sessionCurrent
          ?.getOwnEmailAddressOrUsername() ?? '';
      }

      return NavigationBarWidget(
        imagePaths: _dashboardController.imagePaths,
        accountId: accountId,
        ownEmailAddress: accountDisplayName,
        leadingWidth: ResponsiveUtils.sidebarMenuWidth,
        contactSupportCapability: contactSupportCapability,
        searchForm: SearchInputFormWidget(),
        appGridController:
            _dashboardController.appGridDashboardController,
        settingActionTypes: ProfileSettingActionType.shown(canOpenSettings: canOpenSettings),
        onTapApplicationLogoAction:
            _dashboardController.redirectToInboxAction,
        onTapContactSupportAction: (contactSupport) =>
            _dashboardController.onGetHelpOrReportBug(contactSupport),
        onProfileSettingActionTypeClick: (actionType) =>
            _dashboardController.handleProfileSettingActionTypeClick(
          context: context,
          actionType: actionType,
        ),
      );
    });
  }
}

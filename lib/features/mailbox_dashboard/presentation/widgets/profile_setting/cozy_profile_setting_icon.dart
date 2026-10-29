import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_capabilities_provider.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_profile_setting_action_type_click_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/profile_setting/profile_setting_icon.dart';

/// The avatar menu of the dashboard inside Cozy, on my own account.
class CozyProfileSettingIcon extends ConsumerWidget {
  final _dashboardController = Get.find<MailboxDashBoardController>();

  CozyProfileSettingIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canOpenSettings = ref.watch(shownAccountCapabilitiesProvider).canOpenSettings;
    return Obx(() {
      String accountDisplayName =
          _dashboardController.ownEmailAddress.value;
      if (accountDisplayName.trim().isEmpty) {
        accountDisplayName = _dashboardController
          .sessionCurrent
          ?.getOwnEmailAddressOrUsername() ?? '';
      }
      return ProfileSettingIcon(
        key: const ValueKey(UiKeys.workplaceSettingsButton),
        ownEmailAddress: accountDisplayName,
        settingActionTypes: ProfileSettingActionType.shown(canOpenSettings: canOpenSettings),
        onProfileSettingActionTypeClick: (actionType) =>
          _dashboardController.handleProfileSettingActionTypeClick(
            context: context,
            actionType: actionType,
          ),
        isInsideCozy: true,
      );
    });
  }
}

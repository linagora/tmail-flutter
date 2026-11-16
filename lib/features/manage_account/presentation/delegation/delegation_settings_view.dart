import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegated_to_me_section.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Settings › Delegation: the "Delegated to me" list (ADR-0114).
class DelegationSettingsView extends StatelessWidget {
  static const double _contentMaxWidth = 530;

  const DelegationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final dashboardController = Get.find<ManageAccountDashBoardController>();
    final session = dashboardController.sessionCurrent;
    if (!dashboardController.isDelegationSettingDisplayed) return const SizedBox.shrink();
    final isWebDesktop = responsiveUtils.isWebDesktop(context);

    return SettingDetailViewBuilder(
      responsiveUtils: responsiveUtils,
      child: Container(
        color: SettingsUtils.getContentBackgroundColor(context, responsiveUtils),
        decoration: SettingsUtils.getBoxDecorationForContent(context, responsiveUtils),
        width: double.infinity,
        padding: responsiveUtils.isDesktop(context)
            ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWebDesktop)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    AccountMenuItem.delegation.getName(AppLocalizations.of(context)),
                    style: ThemeUtils.textStyleInter600().copyWith(
                      color: Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              if (session != null)
                Expanded(
                  child: DelegatedToMeSection(
                    session: session,
                    onSessionReloaded: dashboardController.applyReloadedSession,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

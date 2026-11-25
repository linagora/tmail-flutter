import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/delegated_to_me_section.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/delegation/my_delegates_section.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum DelegationTab { byMe, withMe }

/// Settings › Delegation: "By me" lists my delegates (ADR-0115), "With me" the mailboxes delegated to me (ADR-0114).
class DelegationSettingsView extends StatefulWidget {
  const DelegationSettingsView({super.key});

  @override
  State<DelegationSettingsView> createState() => _DelegationSettingsViewState();
}

class _DelegationSettingsViewState extends State<DelegationSettingsView> {
  static const double _contentMaxWidth = 530;

  DelegationTab _tab = DelegationTab.byMe;

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
              if (session != null) ...[
                Align(
                  alignment: responsiveUtils.isMobile(context)
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: _buildTabs(AppLocalizations.of(context)),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: switch (_tab) {
                    DelegationTab.byMe => MyDelegatesSection(session: session),
                    DelegationTab.withMe => DelegatedToMeSection(
                        session: session,
                        onSessionReloaded: dashboardController.applyReloadedSession,
                      ),
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n) {
    return LinagoraSegmentedTabs<DelegationTab>(
      segments: [
        LinagoraSegment(value: DelegationTab.byMe, label: l10n.delegationByMe),
        LinagoraSegment(value: DelegationTab.withMe, label: l10n.delegationWithMe),
      ],
      selected: _tab,
      onChanged: (tab) => setState(() => _tab = tab),
    );
  }
}

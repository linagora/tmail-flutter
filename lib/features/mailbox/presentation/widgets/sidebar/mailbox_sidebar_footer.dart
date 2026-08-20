import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/validate_premium_storage_extension.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxSidebarFooter extends GetWidget<QuotasController> {

  final bool isDesktop;
  final bool showIncreaseSpaceButton;

  const MailboxSidebarFooter({
    super.key,
    this.isDesktop = false,
    this.showIncreaseSpaceButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;
      final octetQuota = dashboardController.octetsQuota.value;

      return LinagoraSidebarFooter(
        children: [
          if (octetQuota?.isStorageUsageIndicatorAppear == true)
            _buildStorage(context, octetQuota!),
          if (_isIncreaseSpaceDisplayed(dashboardController))
            LinagoraSidebarUpsellButton(
              label: AppLocalizations.of(context).increaseYourSpace,
              semanticLabel: AppLocalizations.of(context).increaseYourSpace,
              iconWidget: SvgPicture.asset(
                controller.imagePaths.icPremium,
                fit: BoxFit.contain,
              ),
              expanded: !isDesktop,
              onPressed: () =>
                  dashboardController.paywallController?.navigateToPaywall(),
            ),
          ApplicationVersionWidget(
            title: '${AppLocalizations.of(context).version.toLowerCase()} ',
            builder: (context, version) => LinagoraSidebarVersion(text: version),
          ),
        ],
      );
    });
  }

  Widget _buildStorage(BuildContext context, Quota octetQuota) {
    return LinagoraSidebarStorage(
      label: AppLocalizations.of(context).storageQuotas,
      progress: octetQuota.usedStoragePercent,
      progressState: _storageProgressState(octetQuota),
      status: octetQuota.getQuotasStateTitle(context),
      statusState: octetQuota.isHardLimitReached
        ? LinagoraSidebarStorageStatusState.error
        : LinagoraSidebarStorageStatusState.normal,
      iconWidget: SvgPicture.asset(
        controller.imagePaths.icQuotas,
        colorFilter: LinagoraSidebarStyle.of(context)
            .resolvedStorageIconForeground
            .asFilter(),
        fit: BoxFit.contain,
      ),
      trailing: Obx(() {
        final isLoading = controller.viewState.value.fold(
          (failure) => false,
          (success) => success is GetQuotasLoading,
        );

        return LinagoraSidebarStorageReloadAction(
          isLoading: isLoading,
          onPressed: controller.reloadQuota,
          semanticLabel: AppLocalizations.of(context).refresh,
          iconWidget: SvgPicture.asset(
            controller.imagePaths.icRefreshQuotas,
            colorFilter: LinagoraSidebarStyle.of(context)
                .resolvedStorageIconForeground
                .asFilter(),
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }

  LinagoraSidebarStorageProgressState _storageProgressState(
    Quota octetQuota,
  ) {
    if (octetQuota.isHardLimitReached) {
      return LinagoraSidebarStorageProgressState.full;
    }
    if (octetQuota.isWarnLimitReached) {
      return LinagoraSidebarStorageProgressState.warning;
    }
    return LinagoraSidebarStorageProgressState.normal;
  }

  bool _isIncreaseSpaceDisplayed(
    MailboxDashBoardController dashboardController,
  ) {
    if (!showIncreaseSpaceButton) return false;
    if (dashboardController.paywallController == null) return false;

    return dashboardController.validatePremiumIsAvailable() &&
        dashboardController.octetsQuota.value?.storageAvailable == true;
  }
}

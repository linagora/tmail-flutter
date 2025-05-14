import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_contact_support_capability.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_view_styles.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quota_reload_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasView extends GetWidget<QuotasController> {

  final EdgeInsetsGeometry? padding;
  final bool? isDisplayedContactSupport;

  const QuotasView({
    super.key,
    this.padding,
    this.isDisplayedContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final octetQuota = controller.octetsQuota.value;

      Widget? quotaWidget;

      if (octetQuota != null && octetQuota.storageAvailable) {
        quotaWidget = LayoutBuilder(builder: (context, constraints) {
          return Container(
            padding: padding ?? const EdgeInsetsDirectional.only(
              start: QuotasViewStyles.padding,
              top: QuotasViewStyles.padding,
              bottom: QuotasViewStyles.bottomPadding,
            ),
            margin: controller.responsiveUtils.isWebDesktop(context)
                ? const EdgeInsetsDirectional.only(end: QuotasViewStyles.margin)
                : null,
            decoration: BoxDecoration(
              color: controller.responsiveUtils.isWebDesktop(context)
                  ? QuotasViewStyles.webBackgroundColor
                  : QuotasViewStyles.mobileBackgroundColor,
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      controller.imagePaths.icQuotas,
                      width: QuotasViewStyles.iconSize,
                      height: QuotasViewStyles.iconSize,
                      colorFilter: AppColor.steelGray400.asFilter(),
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(width: QuotasViewStyles.iconPadding),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).storageQuotas,
                        style: const TextStyle(
                          fontSize: QuotasViewStyles.labelTextSize,
                          fontWeight: QuotasViewStyles.labelFontWeight,
                          color: QuotasViewStyles.labelTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: QuotasViewStyles.iconPadding),
                    Obx(() {
                      final isLoading = controller.viewState.value.fold(
                            (failure) => false,
                            (success) => success is GetQuotasLoading,
                      );

                      return QuotaReloadButton(
                        icon: controller.imagePaths.icRefresh,
                        isLoading: isLoading,
                        onTap: controller.reloadQuota,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: QuotasViewStyles.space),
                SizedBox(
                  width: _getProgressBarMaxWith(constraints.maxWidth),
                  child: LinearProgressIndicator(
                    color: octetQuota.getQuotasStateProgressBarColor(),
                    minHeight: QuotasViewStyles.progressBarHeight,
                    backgroundColor: QuotasViewStyles.progressBarBackgroundColor,
                    value: octetQuota.usedStoragePercent,
                  ),
                ),
                const SizedBox(height: QuotasViewStyles.space),
                Text(
                  octetQuota.getQuotasStateTitle(context),
                  style: TextStyle(
                    fontSize: QuotasViewStyles.progressStateTextSize,
                    fontWeight: QuotasViewStyles.progressStateFontWeight,
                    color: octetQuota.getQuotasStateTitleColor(),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          );
        });
      }

      if (isDisplayedContactSupport == true) {
        final contactSupportCapability = controller
            .mailboxDashBoardController
            .contactSupportCapability;

        if (contactSupportCapability != null && contactSupportCapability.isAvailable) {
          final contactSupportWidget = TMailButtonWidget(
            text: AppLocalizations.of(context).getHelpOrReportABug,
            icon: controller.imagePaths.icHelp,
            verticalDirection: true,
            backgroundColor: Colors.transparent,
            maxLines: 2,
            flexibleText: true,
            mainAxisSize: MainAxisSize.min,
            margin: const EdgeInsetsDirectional.only(
              end: 12,
              start: 4,
              top: 6,
              bottom: 6,
            ),
            borderRadius: 10,
            textOverflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColor.primaryColor,
            ),
            onTapActionCallback: () =>
                controller.mailboxDashBoardController.onGetHelpOrReportBug(
                  contactSupportCapability,
                ),
          );

          if (quotaWidget != null) {
            return ColoredBox(
              color: controller.responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
              child: Row(
                children: [
                  Expanded(child: quotaWidget),
                  Expanded(child: contactSupportWidget),
                ],
              ),
            );
          } else {
            return Container(
              color: controller.responsiveUtils.isDesktop(context)
                  ? AppColor.colorBgDesktop
                  : Colors.white,
              width: double.infinity,
              alignment: Alignment.center,
              child: contactSupportWidget,
            );
          }
        }
      }

      if (quotaWidget != null) {
        return quotaWidget;
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  double _getProgressBarMaxWith(double maxWith) {
    if (maxWith > QuotasViewStyles.progressBarMaxWidth) {
      return QuotasViewStyles.progressBarMaxWidth;
    } else {
      return maxWith;
    }
  }
}

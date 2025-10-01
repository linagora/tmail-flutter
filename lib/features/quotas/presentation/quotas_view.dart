import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_view_styles.dart';
import 'package:tmail_ui_user/features/quotas/presentation/widget/quota_reload_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasView extends GetWidget<QuotasController> {

  const QuotasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final octetQuota = controller.mailboxDashBoardController.octetsQuota.value;
      bool isDesktop = controller.responsiveUtils.isDesktop(context);

      if (octetQuota != null && octetQuota.isStorageUsageIndicatorAppear) {
        return Container(
          padding: isDesktop
            ? const EdgeInsetsDirectional.only(
                  start: 10,
                  end: 16,
                  top: 16,
                  bottom: 16,
                )
              : const EdgeInsets.symmetric(vertical: 16),
          margin: isDesktop
            ? const EdgeInsetsDirectional.only(start: 16)
            : const EdgeInsetsDirectional.symmetric(horizontal: 24),
          width: isDesktop ? 224 : double.infinity,
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
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).storageQuotas,
                      style: ThemeUtils.textStyleInter500().copyWith(
                        color: AppColor.steelGray400,
                        fontSize: 12,
                        height: 15.76 / 12,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
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
                      icon: controller.imagePaths.icRefreshQuotas,
                      isLoading: isLoading,
                      onTap: controller.reloadQuota,
                    );
                  }),
                ],
              ),
              const SizedBox(height: QuotasViewStyles.space),
              SizedBox(
                width: isDesktop
                    ? QuotasViewStyles.progressBarMaxWidth
                    : double.infinity,
                child: LinearProgressIndicator(
                  color: octetQuota.getQuotasStateProgressBarColor(),
                  minHeight: QuotasViewStyles.progressBarHeight,
                  backgroundColor: QuotasViewStyles.progressBarBackgroundColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      QuotasViewStyles.progressBarBorderRadius,
                    ),
                  ),
                  value: octetQuota.usedStoragePercent,
                ),
              ),
              const SizedBox(height: QuotasViewStyles.space),
              Text(
                octetQuota.getQuotasStateTitle(context),
                style: ThemeUtils.textStyleInter500().copyWith(
                  color: octetQuota.getQuotasStateTitleColor(),
                  fontSize: 12,
                  height: 15.76 / 12,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        );
      } else {
        return const SizedBox(height: 16);
      }
    });
  }
}

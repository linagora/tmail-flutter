import 'package:core/presentation/extensions/color_extension.dart';
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
      final octetQuota = controller.octetsQuota.value;
      bool isDesktop = controller.responsiveUtils.isDesktop(context);

      if (octetQuota != null && octetQuota.storageAvailable) {
        final quotasWidget = Container(
          padding: isDesktop
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(vertical: 16),
          margin: isDesktop
            ? const EdgeInsetsDirectional.only(start: 8)
            : const EdgeInsetsDirectional.only(start: 24),
          width: isDesktop ? 224 : 196,
          alignment: isDesktop
            ? AlignmentDirectional.center
            : AlignmentDirectional.centerStart,
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColor.steelGray400,
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
                width: QuotasViewStyles.progressBarMaxWidth,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: octetQuota.getQuotasStateTitleColor(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        );

        if (isDesktop) {
          return Center(child: quotasWidget);
        } else {
          return quotasWidget;
        }
      } else {
        return const SizedBox(height: 16);
      }
    });
  }
}

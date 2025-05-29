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

  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final int? labelMaxLines;

  const QuotasView({
    super.key,
    this.padding,
    this.labelStyle,
    this.labelMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final octetQuota = controller.octetsQuota.value;
      if (octetQuota != null && octetQuota.storageAvailable) {
        return LayoutBuilder(builder: (context, constraints) {
          return Container(
            padding: padding ?? const EdgeInsetsDirectional.only(
              start: QuotasViewStyles.padding,
              top: QuotasViewStyles.padding,
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
                        style: labelStyle ?? const TextStyle(
                          fontSize: QuotasViewStyles.labelTextSize,
                          fontWeight: QuotasViewStyles.labelFontWeight,
                          color: QuotasViewStyles.labelTextColor,
                        ),
                        maxLines: labelMaxLines ?? 2,
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
                  style: labelStyle ?? TextStyle(
                    fontSize: QuotasViewStyles.progressStateTextSize,
                    fontWeight: QuotasViewStyles.progressStateFontWeight,
                    color: octetQuota.getQuotasStateTitleColor(),
                  ),
                  maxLines: labelMaxLines ?? 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          );
        });
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

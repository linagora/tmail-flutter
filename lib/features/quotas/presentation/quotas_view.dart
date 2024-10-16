import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_view_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasView extends GetWidget<QuotasController> {

  final EdgeInsetsGeometry? padding;

  const QuotasView({Key? key, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.octetsQuota.value != null && controller.octetsQuota.value!.storageAvailable) {
        final octetQuota = controller.octetsQuota.value!;
        return LayoutBuilder(builder: (context, constraints) {
          return Container(
            padding: padding ?? const EdgeInsetsDirectional.only(
              start: QuotasViewStyles.padding,
              top: QuotasViewStyles.padding,
              bottom: QuotasViewStyles.bottomPadding
            ),
            margin: controller.responsiveUtils.isWebDesktop(context)
              ? const EdgeInsetsDirectional.only(end: QuotasViewStyles.margin)
              : null,
            decoration: BoxDecoration(
              color: controller.responsiveUtils.isWebDesktop(context)
                ? QuotasViewStyles.webBackgroundColor
                : QuotasViewStyles.mobileBackgroundColor,
              border: const Border(
                top: BorderSide(
                  color: QuotasViewStyles.topLineColor,
                  width: QuotasViewStyles.topLineSize,
                )
              ),
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
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(width: QuotasViewStyles.iconPadding),
                    Text(
                      AppLocalizations.of(context).storageQuotas,
                      style: const TextStyle(
                        fontSize: QuotasViewStyles.labelTextSize,
                        fontWeight: QuotasViewStyles.labelFontWeight,
                        color: QuotasViewStyles.labelTextColor
                      ),
                    )
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
                    color: octetQuota.getQuotasStateTitleColor()
                  ),
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/presentation/model/quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_view_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasView extends GetWidget<QuotasController> {

  const QuotasView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.quotasState.value != QuotasState.notAvailable) {
        return LayoutBuilder(builder: (context, constraints) {
          return Container(
            padding: const EdgeInsetsDirectional.only(
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
                top: BorderSide( //                   <--- left side
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
                    color: controller.quotasState.value.getColorProgress(),
                    minHeight: QuotasViewStyles.progressBarHeight,
                    backgroundColor: QuotasViewStyles.progressBarBackgroundColor,
                    value: controller.progressUsedCapacity,
                  ),
                ),
                const SizedBox(height: QuotasViewStyles.space),
                Text(
                  controller.quotasState.value.getQuotasFooterText(
                    context,
                    controller.usedCapacity.value,
                    controller.limitCapacity.value,
                  ),
                  style: TextStyle(
                    fontSize: QuotasViewStyles.progressStateTextSize,
                    fontWeight: QuotasViewStyles.progressStateFontWeight,
                    color: controller.quotasState.value.getColorQuotasFooterText(),
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

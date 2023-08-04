import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_banner_styles.dart';

class QuotasBannerWidget extends StatelessWidget {

  const QuotasBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuotasController>();
    final responsiveUtils = Get.find<ResponsiveUtils>();
    return Obx(() {
      if (controller.octetsQuota.value != null && controller.octetsQuota.value!.allowedDisplayToQuotaBanner) {
        final octetQuota = controller.octetsQuota.value!;
        return Container(
          decoration: BoxDecoration(
            color: octetQuota.getQuotaBannerBackgroundColor(),
            borderRadius: const BorderRadius.all(Radius.circular(QuotasBannerStyles.borderRadius)),
          ),
          margin: EdgeInsetsDirectional.only(
            end: QuotasBannerStyles.endMargin,
            top: PlatformInfo.isWeb ? QuotasBannerStyles.topMargin : 0,
            start: responsiveUtils.isWebDesktop(context) ? 0 : QuotasBannerStyles.startMargin,
            bottom: responsiveUtils.isWebDesktop(context) ? 0 : QuotasBannerStyles.bottomMargin
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: QuotasBannerStyles.horizontalPadding,
            vertical: QuotasBannerStyles.verticalPadding,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                octetQuota.getQuotaBannerIcon(controller.imagePaths),
                width: QuotasBannerStyles.iconSize,
                height: QuotasBannerStyles.iconSize,
                fit: BoxFit.fill,
              ),
              const SizedBox(width: QuotasBannerStyles.iconPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      octetQuota.getQuotaBannerTitle(context),
                      style: TextStyle(
                        fontSize: QuotasBannerStyles.titleTextSize,
                        fontWeight: QuotasBannerStyles.titleFontWeight,
                        color: octetQuota.getQuotaBannerTitleColor(),
                      ),
                    ),
                    const SizedBox(height: QuotasBannerStyles.space),
                    Text(
                      octetQuota.getQuotaBannerMessage(context),
                      style: const TextStyle(
                        fontSize: QuotasBannerStyles.messageTextSize,
                        fontWeight: QuotasBannerStyles.messageFontWeight,
                        color: QuotasBannerStyles.messageTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

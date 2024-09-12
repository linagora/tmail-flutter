import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/features/quotas/presentation/styles/quotas_banner_styles.dart';

class QuotasBannerWidget extends StatelessWidget {

  final QuotasController _quotasController = Get.find<QuotasController>();

  QuotasBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final octetQuota = _quotasController.octetsQuota.value;
      if (octetQuota != null && octetQuota.allowedDisplayToQuotaBanner) {
        return Container(
          decoration: BoxDecoration(
            color: octetQuota.getQuotaBannerBackgroundColor(),
            borderRadius: const BorderRadius.all(Radius.circular(QuotasBannerStyles.borderRadius)),
          ),
          margin: QuotasBannerStyles.getBannerMargin(
            context,
            _quotasController.responsiveUtils),
          padding: QuotasBannerStyles.bannerPadding,
          child: Row(
            children: [
              SvgPicture.asset(
                octetQuota.getQuotaBannerIcon(_quotasController.imagePaths),
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

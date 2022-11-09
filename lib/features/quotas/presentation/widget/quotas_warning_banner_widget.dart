import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasWarningBannerWidget extends GetWidget<QuotasController> {
  const QuotasWarningBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.enableShowWarningQuotas
        ? Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
            decoration: BoxDecoration(
              color: AppColor.colorBackgroundQuotasWarning.withOpacity(0.12),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(controller.imagePaths.icQuotasWarning),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .textQuotasWarningTitle(controller.progressUsedCapacity *100),
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColor.colorTitleQuotasWarning,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)
                            .textQuotasWarningContent,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColor.loginTextFieldHintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}

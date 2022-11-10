import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';

class QuotasWarningBannerWidget extends GetWidget<QuotasController> {
  const QuotasWarningBannerWidget({this.margin ,Key? key}) : super(key: key);
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.enableShowWarningQuotas
        ? Container(
            padding: const EdgeInsets.all(16),
            margin: margin ?? const EdgeInsets.only(left: 12, right: 12, top: 8),
            decoration: BoxDecoration(
              color: controller.quotasState.value.getBackgroundColorWarningBanner(),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(controller.quotasState.value.getIconWarningBanner(controller.imagePaths)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.quotasState.value.getTitleWarningBanner(
                          context,
                          controller.progressUsedCapacity,
                        ),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColor.colorTitleQuotasWarning,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.quotasState.value.getContentWarningBanner(context),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColor.loginTextFieldHintColor,
                        ),
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

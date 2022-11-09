import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasFooterWidget extends GetWidget<QuotasController> {
  const QuotasFooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.enableShowQuotas.value
        ? Container(
            color: AppColor.colorBgDesktop,
            padding: const EdgeInsets.all(24),
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(controller.imagePaths.icQuotas),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).storageQuotas,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColor.loginTextFieldHintColor),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    color: controller.enableShowWarningQuotas ? AppColor.colorProgressQuotasWarning:  AppColor.primaryColor,
                    minHeight: 3,
                    backgroundColor: AppColor.colorDivider,
                    value: controller.progressUsedCapacity,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).textQuotasUsed(
                      controller.usedCapacity.value,
                      controller.softLimitCapacity.value,
                    ),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColor.loginTextFieldHintColor),
                  )
                ],
              ),
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}

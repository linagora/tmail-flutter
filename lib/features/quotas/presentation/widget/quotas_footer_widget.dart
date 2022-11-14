import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/quotas/presentation/model/quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class QuotasFooterWidget extends GetWidget<QuotasController> {
  const QuotasFooterWidget({Key? key, this.padding}) : super(key: key);
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.quotasState.value != QuotasState.notAvailable
        ? Container(
            color: AppColor.colorBgDesktop,
            padding: padding ?? const EdgeInsets.all(24),
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
                    color: controller.quotasState.value.getColorProgress(),
                    minHeight: 3,
                    backgroundColor: AppColor.colorDivider,
                    value: controller.progressUsedCapacity,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.quotasState.value.getQuotasFooterText(
                      context,
                      controller.usedCapacity.value,
                      controller.limitCapacity.value,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: controller.quotasState.value.getColorQuotasFooterText(),
                    ),
                  )
                ],
              ),
            ),
          )
        : const SizedBox.shrink(),
    );
  }
}

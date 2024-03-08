import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/always_read_receipt/always_read_receipt_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AlwaysReadReceiptView extends GetWidget<AlwaysReadReceiptController> with AppLoaderMixin {
  const AlwaysReadReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
      body: Container(
        color: SettingsUtils.getContentBackgroundColor(context, controller.responsiveUtils),
        decoration: SettingsUtils.getBoxDecorationForContent(context, controller.responsiveUtils),
        margin: SettingsUtils.getMarginViewForSettingDetails(context, controller.responsiveUtils),
        padding: SettingsUtils.getPaddingAlwaysReadReceiptSetting(context, controller.responsiveUtils),
        child: Column(
          children: [
            Obx(() {
              if (!controller.isLoading.value) {
                return const SizedBox.shrink();
              }
              return horizontalLoadingWidget;
            }),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  Text(
                    AppLocalizations.of(context).emailReadReceipts,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 24 / 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).emailReadReceiptsSettingExplanation,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 20 / 16,
                      color: AppColor.colorTextSettingDescriptions)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      InkWell(
                        onTap: controller.toggleAlwaysReadReceipt,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Obx(() {
                            return SvgPicture.asset(
                              controller.alwaysReadReceipt.value
                                ? controller.imagePaths.icSwitchOn
                                : controller.imagePaths.icSwitchOff,
                              fit: BoxFit.fill,
                              width: 32,
                              height: 20);
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).emailReadReceiptsToggleDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 20 / 16,
                            color: Colors.black),
                        )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
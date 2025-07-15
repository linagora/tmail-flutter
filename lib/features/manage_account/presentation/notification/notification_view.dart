import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NotificationView extends GetWidget<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SettingsUtils.getBackgroundColor(context, Get.find<ResponsiveUtils>()),
      padding: SettingsUtils.getMarginViewForSettingDetails(context, Get.find<ResponsiveUtils>()),
      child: Obx(() {
        if (controller.notificationSettingEnabled.value == null) {
          return const SizedBox.shrink();
        }
            
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context).showNotifications,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontSize: 17,
                      height: 22 / 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).allowsTwakeMailToNotifyYouWhenANewMessageArrivesOnYourPhone,
                    style: ThemeUtils.defaultTextStyleInterFont.copyWith(
                      fontSize: 15,
                      height: 20 / 15,
                      color: AppColor.colorSettingExplanation),
                  ),
                ],
              )
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: controller.toggleNotificationSetting,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  controller.notificationSettingEnabled.value!
                    ? Get.find<ImagePaths>().icSwitchOn
                    : Get.find<ImagePaths>().icSwitchOff,
                  fit: BoxFit.contain,
                  width: 52,
                  height: 32),
              ),
            ),
          ],
        );
      }),
    );
  }
}
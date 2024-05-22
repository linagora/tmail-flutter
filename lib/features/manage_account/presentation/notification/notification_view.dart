import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class NotificationView extends GetWidget<NotificationController> with AppLoaderMixin {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SettingsUtils.getBackgroundColor(context, controller.responsiveUtils),
      padding: SettingsUtils.getMarginViewForSettingDetails(context, controller.responsiveUtils),
      child: Column(
        children: [
          Obx(() {
            if (!controller.loading) {
              return const SizedBox(height: 3);
            }
            return horizontalLoadingWidget;
          }),
          Expanded(
            child: Container(
              color: SettingsUtils.getContentBackgroundColor(context, controller.responsiveUtils),
              decoration: SettingsUtils.getBoxDecorationForContent(context, controller.responsiveUtils),
              padding: const EdgeInsets.only(top: 8),
              child: ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  Text(
                    AppLocalizations.of(context).notification,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 24 / 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.appNotificationSettingEnabled.value == null) {
                      return const SizedBox.shrink();
                    }
              
                    return Row(
                      children: [
                        InkWell(
                          onTap: controller.toggleAppNotificationSetting,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: SvgPicture.asset(
                              controller.appNotificationSettingEnabled.value!
                                ? controller.imagePaths.icSwitchOn
                                : controller.imagePaths.icSwitchOff,
                              fit: BoxFit.fill,
                              width: 32,
                              height: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).allowAppToSendYouNotifications,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 20 / 16,
                              color: Colors.black),
                          )
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
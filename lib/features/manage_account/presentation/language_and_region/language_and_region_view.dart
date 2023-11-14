
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/change_language_button_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/language_and_region_header_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class LanguageAndRegionView extends GetWidget<LanguageAndRegionController> {

  const LanguageAndRegionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Scaffold(
        backgroundColor: controller.responsiveUtils.isWebDesktop(context)
            ? AppColor.colorBgDesktop
            : Colors.white,
        body: Container(
          width: double.infinity,
          margin: controller.responsiveUtils.isWebDesktop(context)
            ? const EdgeInsets.all(24)
            : EdgeInsets.symmetric(horizontal: SettingsUtils.getHorizontalPadding(context, controller.responsiveUtils)),
          color: controller.responsiveUtils.isWebDesktop(context) ? null : Colors.white,
          decoration: controller.responsiveUtils.isWebDesktop(context)
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.colorBorderBodyThread, width: 1),
                  color: Colors.white)
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                controller.responsiveUtils.isWebDesktop(context) ? 20 : 0),
            child: Padding(
              padding: EdgeInsets.only(
                right: AppUtils.isDirectionRTL(context)
                  ? controller.responsiveUtils.isWebDesktop(context) ? 24 : 0
                  : 0,
                left: AppUtils.isDirectionRTL(context)
                  ? 0
                  : controller.responsiveUtils.isWebDesktop(context) ? 24 : 0,
                top: 24
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LanguageAndRegionHeaderWidget(),
                  const SizedBox(height: 22),
                  Expanded(child: ChangeLanguageButtonWidget())
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}
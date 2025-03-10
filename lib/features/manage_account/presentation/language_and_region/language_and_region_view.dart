import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/change_language_button_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_explanation_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class LanguageAndRegionView extends GetWidget<LanguageAndRegionController> {
  const LanguageAndRegionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: SettingDetailViewBuilder(
        responsiveUtils: controller.responsiveUtils,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.responsiveUtils.isWebDesktop(context))
              ...[
                const SettingHeaderWidget(menuItem: AccountMenuItem.languageAndRegion),
                const Divider(height: 1, color: AppColor.colorDividerHeaderSetting),
              ]
            else
              const SettingExplanationWidget(menuItem: AccountMenuItem.languageAndRegion),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  top: 24,
                  end: 16,
                ),
                child: ChangeLanguageButtonWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

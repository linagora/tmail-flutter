import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/widgets/change_language_button_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
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
        child: Container(
          color: SettingsUtils.getContentBackgroundColor(
            context,
            controller.responsiveUtils,
          ),
          decoration: SettingsUtils.getBoxDecorationForContent(
            context,
            controller.responsiveUtils,
          ),
          width: double.infinity,
          padding: controller.responsiveUtils.isDesktop(context)
              ? const EdgeInsets.symmetric(vertical: 30, horizontal: 22)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.responsiveUtils.isWebDesktop(context))
                SettingHeaderWidget(
                  menuItem: AccountMenuItem.languageAndRegion,
                  textStyle: ThemeUtils.textStyleInter600().copyWith(
                    color: Colors.black.withOpacity(0.9),
                  ),
                  padding: EdgeInsets.zero,
                )
              else
                const SettingExplanationWidget(
                  menuItem: AccountMenuItem.languageAndRegion,
                ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 39),
                  child: ChangeLanguageButtonWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

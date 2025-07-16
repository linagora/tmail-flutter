import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/setting_option_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/widgets/setting_option_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/widgets/setting_header_widget.dart';

class PreferencesView extends GetWidget<PreferencesController> with AppLoaderMixin {
  const PreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (!controller.isLoading) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: SettingsUtils.getSettingProgressBarPadding(
              context,
              controller.responsiveUtils,
            ),
            child: horizontalLoadingWidget,
          );
        }),
        Expanded(
          child: SettingDetailViewBuilder(
            responsiveUtils: controller.responsiveUtils,
            padding: SettingsUtils.getSettingContentWithoutHeaderPadding(
              context,
              controller.responsiveUtils,
            ),
            child: Container(
              color: SettingsUtils.getContentBackgroundColor(
                context, controller.responsiveUtils,
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
                    const SettingHeaderWidget(
                      menuItem: AccountMenuItem.preferences,
                      padding: EdgeInsets.only(bottom: 21),
                    ),
                  Obx(() {
                    final settingOption = controller.settingOption.value;
                    final localSettingOption = controller.localSettings;

                    if (settingOption == null && (localSettingOption.value?.isEmpty ?? true)) {
                      return const SizedBox.shrink();
                    }

                    final availableSettingOptions = [
                      if (settingOption != null) ...SettingOptionType.values.where(
                        (optionType) => !optionType.isLocal,
                      ),
                      ...SettingOptionType.values.where(
                        (optionType) => optionType.isLocal,
                      ),
                    ];

                    return Expanded(
                      child: ListView.separated(
                        itemCount: availableSettingOptions.length,
                        itemBuilder: (context, index) {
                          return SettingOptionItem(
                            imagePaths: controller.imagePaths,
                            settingOption: settingOption,
                            localSettings: localSettingOption.value ?? {},
                            optionType: availableSettingOptions[index],
                            onTapSettingOptionAction: controller.updateStateSettingOption,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 49),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
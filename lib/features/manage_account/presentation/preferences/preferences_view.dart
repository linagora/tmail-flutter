import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/base/setting_detail_view_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/setting_option_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/widgets/setting_option_item.dart';

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
            padding: controller.responsiveUtils.isTablet(context)
              ? const EdgeInsetsDirectional.only(start: 32, end: 32, top: 16)
              : const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16),
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
              padding: SettingsUtils.getPreferencesSettingPadding(
                context,
                controller.responsiveUtils,
              ),
              child: Obx(() {
                final settingOption = controller.settingOption.value;
                final localSettingOption = controller.localSettings;

                if (settingOption == null && localSettingOption.isEmpty) {
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

                return ListView.separated(
                  itemCount: availableSettingOptions.length,
                  itemBuilder: (context, index) {
                    return SettingOptionItem(
                      imagePaths: controller.imagePaths,
                      settingOption: settingOption,
                      localSettings: localSettingOption,
                      optionType: availableSettingOptions[index],
                      onTapSettingOptionAction: controller.updateStateSettingOption,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 60),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}